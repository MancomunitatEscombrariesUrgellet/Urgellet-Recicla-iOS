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

class ScanningMessageViewController: UIViewController {
    
    var missatge: Missatge?
    
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var bottomImageView: UIImageView!
    @IBOutlet weak var indicatorIcon: UIImageView!
    @IBOutlet weak var indicatorLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    
    @IBOutlet weak var checkIcon: UIImageView!
    @IBOutlet weak var checkView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicatorView.alpha = 0

        plusButton.layer.borderWidth = 2.0
        plusButton.layer.cornerRadius = 25.0
        plusButton.layer.borderColor = UIColor.white.cgColor

        self.checkView.transform = CGAffineTransform(scaleX: 0, y: 0)

        if let msg = missatge{
            descLabel.text = msg.missatge
            bottomImageView.image = UIImage(named: msg.imatge!)
            if (msg.link?.isEmpty)!{
                plusButton.isHidden = true
            }
            
            let boldAttribute = [ NSAttributedStringKey.font: UIFont(name: "Glegoo-Bold", size: 15) , NSAttributedStringKey.foregroundColor: UIColor.white ]
            let normalAttribute = [ NSAttributedStringKey.font:UIFont(name: "Glegoo-Regular", size: 13), NSAttributedStringKey.foregroundColor: Constants.Colors.TintColor ]
            
            let firstString = NSMutableAttributedString(string: "Has reciclat ", attributes: normalAttribute )
      
            switch msg.fraccio {
            case Constants.Fraccions.Organica:
                indicatorIcon.image = UIImage(named: "organica")
                firstString.append(NSAttributedString(string: "ORGÀNICA " , attributes: boldAttribute))
            case Constants.Fraccions.Resta:
                firstString.append(NSAttributedString(string: "RESTA " , attributes: boldAttribute))
                indicatorIcon.image = UIImage(named: "resta")
            case Constants.Fraccions.Papel:
                firstString.append(NSAttributedString(string: "PAPER " , attributes: boldAttribute))
                indicatorIcon.image = UIImage(named: "paper")
            case Constants.Fraccions.Envases:
                firstString.append(NSAttributedString(string: "ENVASOS " , attributes: boldAttribute))
                indicatorIcon.image = UIImage(named: "envasos")
            case Constants.Fraccions.Vidrio:
                firstString.append(NSAttributedString(string: "VIDRE " , attributes: boldAttribute))
                indicatorIcon.image = UIImage(named: "vidre")
            default:
                break
            }
            firstString.append(NSAttributedString(string: "correctament!" , attributes: normalAttribute))

            indicatorLabel.attributedText = firstString

        }
        // Do any additional setup after loading the view.
    }
    
 
    override func viewDidAppear(_ animated: Bool) {
        indicatorView.layer.cornerRadius = indicatorView.bounds.size.width / 2
        indicatorView.layer.borderColor = Constants.Colors.TintColor.cgColor
        UIView.animate(withDuration: 0.3, animations: {
            self.indicatorView.alpha = 1
        }, completion: nil)
        
        checkIcon.tintColor = Constants.Colors.TintColor
        checkView.layer.borderWidth = 3.0
        checkView.layer.cornerRadius = checkView.bounds.size.width / 2
        checkView.layer.borderColor = Constants.Colors.TintColor.cgColor
        
        UIView.animate(withDuration: 0.8,
                       delay:0.3,
                       usingSpringWithDamping:0.50,
                       initialSpringVelocity:0.2,
                       options: .curveEaseOut,
                       animations: {
                        
                        self.checkView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: {
            //Code to run after animating
            (value: Bool) in
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func linkAction(_ sender: Any) {
        if let link = missatge?.link{
            UIApplication.shared.openURL(URL(string: link)!)

        }
    }
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
