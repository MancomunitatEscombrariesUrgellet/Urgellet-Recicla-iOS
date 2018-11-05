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
import RealmSwift
import APESuperHUD

class LoginViewController: UIViewController, UserData {
    
    let realm = try! Realm()
    var phoneMode = true
    var codeFake = ""
    var savedPhone = ""
    
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var resendSmsButton: UIButton!
    var seconds = 60
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.alpha = 0.4
        doneButton.isEnabled = false
        phoneTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        topLabel.textColor = Constants.Colors.TintColor
        topLabel.text = NSLocalizedString("Benvingut a Urgellet Recicla Link!", comment: "Benvingut a Urgellet Recicla Link!")

        
        headerLabel.textColor = Constants.Colors.TintColor
        headerLabel.text = NSLocalizedString("Introdueix el teu número de telèfon", comment: "Introdueix el teu número de telèfon")
        phoneTextField.becomeFirstResponder()
        doneButton.backgroundColor = Constants.Colors.TintColor

       
        
        self.view.backgroundColor = Constants.Colors.BackgroundColor
        // Do any additional setup after loading the view.
        changeButton.titleLabel?.textColor = Constants.Colors.TintColor
        changeButton.tintColor =  Constants.Colors.TintColor
        changeButton.setTitle(NSLocalizedString("Posa el codi", comment: "Posa el codi"), for: .normal)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.text?.isEmpty)!{
            doneButton.alpha = 0.4
            doneButton.isEnabled = false
        }
        else{
            doneButton.alpha = 1
            doneButton.isEnabled = true
        }
    }
    
    @objc func tap(gesture: UITapGestureRecognizer) {
        if(!phoneMode){
            phoneTextField.resignFirstResponder()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = Constants.Colors.TintColor.cgColor
        
        border.frame = CGRect(x: 0, y: phoneTextField.frame.size.height - width, width:  phoneTextField.frame.size.width, height: phoneTextField.frame.size.height)
        
        border.borderWidth = width
        phoneTextField.layer.addSublayer(border)
        phoneTextField.layer.masksToBounds = true
    }
    
    @IBAction func changeAction(_ sender: Any) {
        phoneMode = !phoneMode
        
        if(phoneMode){
            headerLabel.text = NSLocalizedString("Introdueix el teu número de telèfon", comment: "Introdueix el teu número de telèfon")
            changeButton.setTitle(NSLocalizedString("Posa el codi", comment: "Posa el codi"), for: .normal)

        }
        else{
            self.changeButton.setTitle(NSLocalizedString("Posa el teu telèfon", comment: "Posa el teu telèfon"), for: .normal)
            
            self.headerLabel.text = NSLocalizedString("Posa el codi que has rebut per SMS", comment: "Posa el codi que has rebut per SMS")
        }
    }
    
    fileprivate func initSmsTimer() {
        self.timer = Timer.every(1.second, {
            self.seconds -= 1
            if self.seconds == 0 {
                self.countdownLabel.text = "00:00"
                self.timer?.invalidate()
                self.resendSmsButton.alpha = 1
                self.resendSmsButton.isEnabled = true
            } else if self.seconds > 9 {
                self.countdownLabel.text = "00:\(self.seconds)"
            } else {
                self.countdownLabel.text = "00:0\(self.seconds)"
            }
        })
    }
    
    fileprivate func afterPostTelf(_ dirtyJSON: [String : AnyObject]) {
        if let codeDict = dirtyJSON as? [String: AnyObject], let code = codeDict["codigo_sms"] as? String{
            self.codeFake = code
            self.phoneMode = false
            
            self.changeButton.setTitle(NSLocalizedString("Posa el teu telèfon", comment: "Posa el teu telèfon"), for: .normal)
            
            self.headerLabel.text = NSLocalizedString("Posa el codi que has rebut per SMS", comment: "Posa el codi que has rebut per SMS")
            self.phoneTextField.text = ""
        }
        else if let errorDict = dirtyJSON as? [String: AnyObject], let message = errorDict["message"] as? String{
            self.alertWithText(text: message)
        }
        self.view.endEditing(true)
        self.resendSmsButton.alpha = 0.4
        self.resendSmsButton.isEnabled = false
        self.countdownLabel.text = "00:59"
        self.doneButton.alpha = 0.4
        self.doneButton.isEnabled = false
        self.seconds = 60
    }
    
    fileprivate func sendPhone(_ params: [String : AnyObject]) {
        savedPhone = phoneTextField.text!
        
        //TODO LOGIN
    }
    
    @IBAction func fetAction(_ sender: Any) {
//         APESuperHUD.showOrUpdateHUD(loadingIndicator: .standard, message: "", presentingView: self.view)
        APESuperHUD.show(style: .loadingIndicator(type: .standard), title: nil, message: "")
        if(phoneMode){
            var params = [String: AnyObject]()
            if let phoneInt = Int(phoneTextField.text!){
                params["telefono"] = phoneInt as AnyObject?
                sendPhone(params)
            }
        }
        else{
            
            if Int(phoneTextField.text!) != nil{
                //TODO SEND CODE
            }
        }
    }
    
    @IBAction func resendSMSAction(_ sender: Any) {
        var params = [String: AnyObject]()
        if let phoneInt = Int(savedPhone){
            params["telefono"] = phoneInt as AnyObject?
            
            sendPhone(params)
        }
    }
    
    func alertWithText(text: String){
        let alertController = UIAlertController(title: "Urgellet", message: text, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
