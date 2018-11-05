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
import SwiftyTimer
import AudioToolbox
import APESuperHUD
import SwiftEventBus

class QRScanningViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UserData, FlashActions {

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
        flashOff()
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
//        Singleton.sharedInstance.initTimer()
        //declare this property where it won't go out of scope relative to your listener
       
//        refreshToken()
        
        // DELETE, CALL HERE ONLY FOR TEST
//        self.getUser()
        SwiftEventBus.onMainThread(self, name: "updateBadge") { result in
            let count: String? = result?.object as? String
            self.tabBarController?.tabBar.items?[1].badgeValue = count
        }
      
        SwiftEventBus.onMainThread(self, name: "loggedOut") { result in
            print("event logout")
            self.goToLoginController()
        }
        
        if let user = UserDataAccess.getUser() {
            if (user.loggedOut == true) {
                goToLoginController()
                print("USER LOGGED OUT!!!!!!")
            }
        }
        
        self.tabBarItem.title = ""
        tabBarItem.imageInsets = UIEdgeInsets(top: 9, left: 0, bottom: -9, right: 0)

        self.view.backgroundColor = Constants.Colors.BackgroundColor
        doneButton.backgroundColor = Constants.Colors.TintColor
        doneButton.setTitle(NSLocalizedString("He acabat de reciclar", comment: "He acabat de reciclar"), for: .normal)
        labelIntruction.text = NSLocalizedString("Llegeix el codi QR del contenidor", comment: "Llegeix el codi QR del contenidor")
        labelIntruction.textColor = Constants.Colors.TintColor
    }
    
    func goToLoginController() {
        let loginViewController = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(loginViewController, animated: true)
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
            
            if metadataObj.stringValue != nil && !Singleton.sharedInstance.codesArray.contains(metadataObj.stringValue!){
                 print(metadataObj.stringValue)
                if let qr = metadataObj.stringValue{
                    let qrArray = qr.components(separatedBy: "/")
                    
                    if let lastElement = qrArray.last, let lastInt = Int(lastElement){
                        let objects = realm.objects(Elemento.self).filter("nfc = %i", lastInt)
                        print(objects.count)
                        if objects.count > 0{
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

                            postRegistrar(id: objects.first!.id, nfc: lastInt, registered: true)
                            
                            Singleton.sharedInstance.codesArray.append(metadataObj.stringValue!)
                            
                            Timer.after(15.seconds) {
                                if  Singleton.sharedInstance.codesArray.contains(metadataObj.stringValue!){
                                    Singleton.sharedInstance.codesArray.remove(at: Singleton.sharedInstance.codesArray.index(of: metadataObj.stringValue!)!)
                                }
                            }
                        }
                        else{
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                            Singleton.sharedInstance.codesArray.append(metadataObj.stringValue!)
                            Timer.after(15.seconds) {
                                if  Singleton.sharedInstance.codesArray.contains(metadataObj.stringValue!){
                                    Singleton.sharedInstance.codesArray.remove(at: Singleton.sharedInstance.codesArray.index(of: metadataObj.stringValue!)!)
                                }
                            }
                            postRegistrar(id: -1,  nfc: lastInt,  registered: false)
                        }
                    }
                }
               
            }
        }
    }

    func postRegistrar(id: Int, nfc: Int, registered: Bool){
        
//        APESuperHUD.showOrUpdateHUD(loadingIndicator: .standard, message: "", presentingView: self.view)
        APESuperHUD.show(style: .loadingIndicator(type: .standard), title: nil, message: "")
        var params = [String: AnyObject]()

        params["modo"] = 2 as AnyObject?
        params["timestamp"] = Date().timeIntervalSince1970 as AnyObject?
        params["nfc"] = [nfc] as AnyObject?

        let user = realm.objects(User.self)
        if user.count > 0{
            params["idActuacion"] = "\(user.first!.registradoAct)" as AnyObject?
        }
        
        if (LocationManager.sharedInstance.locValue != nil){
            params["latitud"] = LocationManager.sharedInstance.locValue?.latitude as AnyObject?
            params["longitud"] = LocationManager.sharedInstance.locValue?.longitude as AnyObject?

        }
        
        params["idVivienda"] = UserDefaults.standard.value(forKey: "idVivienda") as AnyObject?
        print(params)
        
        //TODO REGISTRAR
    }
    
    private func showThanks(responseCompleteJSON: [String: Any]?, nfc: Int, registered: Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let JSON = responseCompleteJSON as? [String: AnyObject]{
            let test = false
            if UserDefaults.standard.integer(forKey: "showMessage") == 2 || test == true {
                self.screenMessage(nfc: nfc)
            }
            else{
                self.screenNoMessage(nfc: nfc, registered: registered)
            }
        }
    }
    
    private func screenNoMessage(nfc: Int, registered: Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let scanningSuccess = storyboard.instantiateViewController(withIdentifier: "ScanningSuccessViewController") as! ScanningSuccessViewController
        if(!registered){
            scanningSuccess.message = NSLocalizedString("RespostaDefecte", comment: "RespostaDefecte")
        } else {
            let objects = self.realm.objects(Elemento.self).filter("nfc = %i", nfc)
            if objects.count > 0 {
                
                scanningSuccess.elemento = objects.first!
                if let valor = objects.first!.fraccion.value{
                    switch valor {
                    case Constants.Fraccions.Organica:
                        scanningSuccess.message = NSLocalizedString("RespostaDefecteOrganica", comment: "RespostaDefecteOrganica")
                    case Constants.Fraccions.Resta:
                        scanningSuccess.message = NSLocalizedString("RespostaDefecteResta", comment: "RespostaDefecteResta")
                    case Constants.Fraccions.Papel:
                        scanningSuccess.message = NSLocalizedString("RespostaDefectePaper", comment: "RespostaDefectePaper")
                    case Constants.Fraccions.Envases:
                        scanningSuccess.message = NSLocalizedString("RespostaDefecteEnvasos", comment: "RespostaDefecteEnvasos")
                    case Constants.Fraccions.Vidrio:
                        scanningSuccess.message = NSLocalizedString("RespostaDefecteVidre", comment: "RespostaDefecteVidre")
                    default:
                        scanningSuccess.message = NSLocalizedString("RespostaDefecte", comment: "RespostaDefecte")
                    }
                }
            }
        }
        var show = UserDefaults.standard.integer(forKey: "showMessage")
        show += 1
        UserDefaults.standard.set(show, forKey: "showMessage")
        self.navigationController?.pushViewController(scanningSuccess, animated: true)
    }
    
    private func screenMessage(nfc: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let messageVC = storyboard.instantiateViewController(withIdentifier: "ScanningMessageViewController") as! ScanningMessageViewController
        let objects = self.realm.objects(Elemento.self).filter("nfc = %i", nfc)
        if objects.count > 0{
            
            let messages = self.realm.objects(Missatge.self).filter("fraccio = %i && mostrat = false", objects.first!.fraccion)
            if messages.count == 0{
                let messagesAll = self.realm.objects(Missatge.self).filter("fraccio = %i", objects.first!.fraccion)
                for message in messagesAll{
                    try! self.realm.write {
                        message.mostrat = false
                    }
                }
                let messages = self.realm.objects(Missatge.self).filter("fraccio = %i && mostrat = false", objects.first!.fraccion)
                let missatge = messages.first
                try! self.realm.write {
                    missatge?.mostrat = true
                }
                messageVC.missatge = missatge
            }
            else{
                let missatge = messages.first
                try! self.realm.write {
                    missatge?.mostrat = true
                }
                messageVC.missatge = missatge
            }
        }
        self.navigationController?.pushViewController(messageVC, animated: true)
        var show = UserDefaults.standard.integer(forKey: "showMessage")
        show = 0
        UserDefaults.standard.set(show, forKey: "showMessage")
    }

    func alertWithText(text: String){
        let alertController = UIAlertController(title: "Urgellet", message: text, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
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
