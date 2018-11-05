/*
Aplicació mòbil que permet implementar sistemes de pagament per generació de residus enfocats a bonificar els usuaris en base al seu bon comportament. Mitjançant la lectura de codis QR adherits als contenidors, el ciutadà pot informar proactivament al seu ajuntament de les seves actuacions de reciclatge i rebre bonificacions en base a actuacions positives.
Copyright (C) 2018  Urgellet Recicla

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

Contact email meu@urgellet.cat

The GNU General Public License does not permit incorporating your program
into proprietary programs.  If your program is a subroutine library, you
may consider it more useful to permit linking proprietary applications with
the library.  If this is what you want to do, use the GNU Lesser General
Public License instead of this License.  But first, please read
<https://www.gnu.org/licenses/why-not-lgpl.html>.
*/

import UIKit
import AVFoundation
import RealmSwift

class IncidenciesQRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UserData, FlashActions {
    
    let realm = try! Realm()
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIImageView?
    
    let supportedCodeTypes = [AVMetadataObject.ObjectType.qr]
    
    @IBOutlet weak var viewScanner: UIView!
    @IBOutlet weak var labelIntruction: UILabel!
    @IBOutlet weak var doneButton: UIButton!    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
        self.flashOff()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            let screenSize = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            videoPreviewLayer?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth)
            viewScanner.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIImageView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.frame = CGRect(x:40,y:40,width:screenWidth - 80,height:screenWidth - 80 )
                qrCodeFrameView.image = UIImage(named: "marc")
                viewScanner.addSubview(qrCodeFrameView)
                viewScanner.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        flashOn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let scanningSuccess = storyboard.instantiateViewController(withIdentifier: "IncidenciaSuccessViewController") as! IncidenciaSuccessViewController
        self.navigationController?.pushViewController(scanningSuccess, animated: true)
        */
        
        getElementos()
        
       // self.title = NSLocalizedString("Inici", comment: "Inici")
        self.view.backgroundColor = Constants.Colors.BackgroundColor
        doneButton.backgroundColor = Constants.Colors.TintColor
        doneButton.setTitle(NSLocalizedString("He acabat de reciclar", comment: "He acabat de reciclar"), for: .normal)
        labelIntruction.text = NSLocalizedString("Llegeix el codi QR del contenidor per ajudar-nos a detectar incidències", comment: "Llegeix el codi QR del contenidor per ajudar-nos a detectar incidències")
        labelIntruction.textColor = Constants.Colors.TintColor

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let scanningSuccess = storyboard.instantiateViewController(withIdentifier: "IncidenciesViewController") as! IncidenciesViewController
        scanningSuccess.nfcElemento = 99012
    }
    
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate Methods
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            let screenSize = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            qrCodeFrameView?.frame = CGRect(x:40,y:40,width:screenWidth - 80,height:screenWidth - 80 )
            
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil && !Singleton.sharedInstance.codesIncidenciesArray.contains(metadataObj.stringValue!){
                print(metadataObj.stringValue)
                if let qr = metadataObj.stringValue{
                    let qrArray = qr.components(separatedBy: "/")
                    if let lastElement = qrArray.last, let lastInt = Int(lastElement){
                        Singleton.sharedInstance.codesIncidenciesArray.append(metadataObj.stringValue!)

                        Timer.after(3.seconds) {
                            if  Singleton.sharedInstance.codesIncidenciesArray.contains(metadataObj.stringValue!){
                                Singleton.sharedInstance.codesIncidenciesArray.remove(at: Singleton.sharedInstance.codesIncidenciesArray.index(of: metadataObj.stringValue!)!)
                            }
                        }
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let scanningSuccess = storyboard.instantiateViewController(withIdentifier: "IncidenciesViewController") as! IncidenciesViewController
                        scanningSuccess.nfcElemento = lastInt
                        
                        let objects = self.realm.objects(Elemento.self).filter("nfc = %i", lastInt)
                        if objects.count > 0{
                            
                            scanningSuccess.elemento = objects.first!
                        }
                        
                        self.navigationController?.pushViewController(scanningSuccess, animated: true)
                    }
                }
            }
        }
    }
    
    
    @IBAction func donePressed(_ sender: Any) {
        self.performSegue(withIdentifier: "segueScanned", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
