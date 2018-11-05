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

class SalariRootViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let realm = try! Realm()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let notificationName = Notification.Name("salari")
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: notificationName, object: nil)
        
        let notificationName2 = Notification.Name("salariDeixalleria")
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: notificationName2, object: nil)
        
        
        // Do any additional setup after loading the view.
    }

    @objc func reload(){
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let notificationName = Notification.Name("salariDeixalleria")
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil);
        
        let notificationName2 = Notification.Name("salari")
        NotificationCenter.default.removeObserver(self, name: notificationName2, object: nil);
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.size.height / 3

        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "salariCell", for: indexPath) as! SalariRootTableViewCell
        switch indexPath.row {
        case 0:
            cell.labelTitol.text = "Descompte contenidors"
            cell.labelSubtitol.text = "0€"

            let salari = realm.objects(Salari.self)
            if salari.count > 0{
                
                if let saldo = salari.first!.saldo_2{
                    cell.labelSubtitol.text = saldo

                }
            }
            
            cell.icon.image = UIImage(named: "desc_cont")
        case 1:
            cell.labelTitol.text = "Descompte deixalleria"
            cell.labelSubtitol.text = "0€"
            
            let salari = realm.objects(SalariDeixalleria.self)
            if salari.count > 0{
                
                if let saldo = salari.first!.saldo_2{
                    cell.labelSubtitol.text = saldo
                    
                }
            }
            
            cell.icon.image = UIImage(named: "desc_deix")

        case 2:
            cell.labelTitol.text = "Historial de descomptes"
            cell.labelSubtitol.text = ""
            cell.icon.image = UIImage(named: "desc_histo")

        default:
           break
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.row {
        case 0:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let atencioVC = storyboard.instantiateViewController(withIdentifier: "SalariViewController") as! SalariViewController
            self.navigationController?.pushViewController(atencioVC, animated: true)

        case 1:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let atencioVC = storyboard.instantiateViewController(withIdentifier: "SalariDeixalleriaViewController") as! SalariDeixalleriaViewController
            self.navigationController?.pushViewController(atencioVC, animated: true)

            
        case 2:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let atencioVC = storyboard.instantiateViewController(withIdentifier: "HistorialDescomptesViewController") as! HistorialDescomptesViewController
            self.navigationController?.pushViewController(atencioVC, animated: true)
            
        default:
            break
        }
    }
}
