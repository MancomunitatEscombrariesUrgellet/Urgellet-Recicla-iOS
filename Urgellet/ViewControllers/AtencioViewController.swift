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

class AtencioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var headerSubLabel: UILabel!
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        let predicate = NSPredicate(format: "idVivienda = %i", UserDefaults.standard.value(forKey: "idVivienda") as! Int)
        if let contrato = realm.objects(Contrato.self).filter(predicate).first{
            headerLabel.text = contrato.descripcion
            headerSubLabel.text = "Contracte \(contrato.idVivienda)"
        }
    
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
    }

    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "atencioImageCell", for: indexPath)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "atencioCell", for: indexPath) as! AtencioTableViewCell
            cell.labelTitol.text = "Av. Valira, 3bx\nLa Seu D'Urgell\nTel. 973 355 600\n900 70 10 46\ninfo@meu.cat"
      
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "atencioCell", for: indexPath) as! AtencioTableViewCell
            cell.labelTitol.text = "Horari d'atenció al públic:\nDe dilluns a divendres\nde 8:00 a 15:00"
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "perfilHeaderCell", for: indexPath) as! PerfilHeaderTableViewCell
            return cell
        }
    }
}
