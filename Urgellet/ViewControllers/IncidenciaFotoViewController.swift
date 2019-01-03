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
import APESuperHUD

class IncidenciaFotoViewController: UIViewController {
    
    @IBOutlet weak var buttonTornaAFer: UIButton!
    @IBOutlet weak var buttonEnvia: UIButton!
    @IBOutlet weak var labelTitol: UILabel!
    @IBOutlet weak var viewCamera: UIView!
    @IBOutlet weak var previewImageView: UIImageView!
    
    var nfcElemento: Int?

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var frontCamera = false
    let stillImageOutput = AVCaptureStillImageOutput()
    var error: NSError?
    
    let realm = try! Realm()

    var actuacion: Actuacion?
    
    var elemento: Elemento?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(actuacion?.id)
        
        self.view.backgroundColor = Constants.Colors.BackgroundColor
        
        buttonTornaAFer.backgroundColor = Constants.Colors.TintColor
        buttonEnvia.backgroundColor = Constants.Colors.TintColor
        
        buttonTornaAFer.setTitle(NSLocalizedString("Torna a fer la foto", comment: "Torna a fer la foto"), for: .normal)
        buttonEnvia.setTitle(NSLocalizedString("Enviar la foto", comment: "Enviar la foto"), for: .normal)
        
        self.labelTitol.text = NSLocalizedString("Fes una fotografia de la incidencia", comment: "Fes una fotografia de la incidencia")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        reloadCamera()
    }
    
    
    func reloadCamera() {
        previewLayer?.removeFromSuperlayer()
        
        captureSession = AVCaptureSession()
        var videoCaptureDevice:AVCaptureDevice! = nil
        // var backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if (frontCamera == true) {
            let videoDevices = AVCaptureDevice.devices(for: AVMediaType.video)
            
            for device in videoDevices{
                let device = device 
                if device.position == AVCaptureDevice.Position.front {
                    videoCaptureDevice = device
                    break
                }
            }
        } else {
            videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed();
            return;
        }
        
        stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
        previewLayer.frame = viewCamera.layer.bounds;
        print(viewCamera.layer.bounds)
        
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill;
        viewCamera.layer.addSublayer(previewLayer);
        
        captureSession.startRunning();
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning();
        }
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        if let videoConnection = stillImageOutput.connection(with: AVMediaType.video) {
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!)
                
                self.buttonEnvia.isHidden = false
                self.buttonTornaAFer.isHidden = false
                
                self.previewImageView.isHidden = false
                
                let finalImage = self.cropToPreviewLayer(originalImage: UIImage(data: imageData!)!)
                print(finalImage.size)
                self.previewImageView.image = finalImage
                
                let device = AVCaptureDevice.default(for: AVMediaType.video)
                if (device?.hasTorch)! {
                    do {
                        try device?.lockForConfiguration()
                        device?.torchMode = AVCaptureDevice.TorchMode.off
                        
                        device?.unlockForConfiguration()
                    } catch {
                        print(error)
                    }
                }
                
            }
        }
    }
    
    private func cropToPreviewLayer(originalImage: UIImage) -> UIImage {
        let outputRect = previewLayer.metadataOutputRectConverted(fromLayerRect: previewLayer.bounds)
        var cgImage = originalImage.cgImage!
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let cropRect = CGRect(x: outputRect.origin.x * width, y: outputRect.origin.y * height, width: outputRect.size.width * width, height: outputRect.size.height * height)
        
        cgImage = cgImage.cropping(to: cropRect)!
        let croppedUIImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: originalImage.imageOrientation)
        
        return croppedUIImage
    }
    
    @IBAction func reloadAction(_ sender: Any) {
        self.buttonEnvia.isHidden = true
        self.buttonTornaAFer.isHidden = true
        
        self.previewImageView.isHidden = true
        
    }
    
    @IBAction func envia(_ sender: Any) {
     
//        APESuperHUD.showOrUpdateHUD(loadingIndicator: .standard, message: "", presentingView: self.view)
        APESuperHUD.show(style: .loadingIndicator(type: .standard), title: nil, message: "")
        let image = self.previewImageView.image
        
        let idEl = nfcElemento!
        let user = realm.objects(User.self)
        
        var latitud = 0.0
        var longitud = 0.0
        if (LocationManager.sharedInstance.locValue != nil){
            latitud = (LocationManager.sharedInstance.locValue?.latitude)!
            longitud = (LocationManager.sharedInstance.locValue?.longitude)!
        }
        
        let resizedImage = self.resizeImage(image: image!, newWidth: 500)
        let imageReady = UIImageJPEGRepresentation(resizedImage!, 1)

        if(user.count > 0){
            //TODO get Quarter Discount PDF from server with Periodo class using indexPath and show it on PDFViewController and close APESuperHUD
        }
    }

    
    func alertWithText(text: String){
        let alertController = UIAlertController(title: "Urgellet", message: text, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    @IBAction func toggleFlash(_ sender: Any) {
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureDevice.TorchMode.on) {
                    device?.torchMode = AVCaptureDevice.TorchMode.off
                } else {
                    do {
                        try device?.setTorchModeOn(level: 1.0)
                    } catch {
                        print(error)
                    }
                }
                device?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
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

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
