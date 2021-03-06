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

class ScanningDoneViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var indicatorIcon: UIImageView!
    @IBOutlet weak var indicatorLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Constants.Colors.BackgroundColor

        doneButton.backgroundColor = Constants.Colors.TintColor
        doneButton.setTitle(NSLocalizedString("Tornar a l'inici", comment: "Tornar a l'inici"), for: .normal)

        self.indicatorIcon.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        indicatorIcon.tintColor = Constants.Colors.TintColor
        indicatorView.layer.borderColor = Constants.Colors.TintColor.cgColor
        indicatorLabel.textColor = Constants.Colors.TintColor
        indicatorLabel.text = NSLocalizedString("Has llençat la deixalla orgànica correctament", comment: "Has llençat la deixalla orgànica correctament")
        // Do any additional setup after loading the view.
        Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(animateLogoOn), userInfo: nil, repeats: true)

    }

    
    @objc func animateLogoOn(){
        UIView.animate(withDuration: 0.8,
                       delay:0.0,
                       usingSpringWithDamping:0.50,
                       initialSpringVelocity:0.2,
                       options: .curveEaseOut,
                       animations: {
                        
                        self.indicatorIcon.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: {
            //Code to run after animating
            (value: Bool) in
        })
    }
    
    @IBAction func donePressed(_ sender: Any) {
        Singleton.sharedInstance.codesArray = [String]()
        self.navigationController?.popToRootViewController(animated: true)
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
