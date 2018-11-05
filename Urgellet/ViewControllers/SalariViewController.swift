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

class SalariViewController: UIViewController {
    
    let realm = try! Realm()
    var selectedIndexes = [Int]()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelNoData: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Constants.Colors.BackgroundColor
        self.tableView.backgroundColor = Constants.Colors.BackgroundColor
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tableView.tableFooterView = footer
        
        let notificationName = Notification.Name("salari")
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: notificationName, object: nil)
        
        let salari = realm.objects(Salari.self)
        if salari.count > 0{
            
           
            if salari.first!.interacciones.count > 0{
                labelNoData.isHidden = true
                tableView.isHidden = false
            }
            else{
                labelNoData.isHidden = false
                tableView.isHidden = true
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let notificationName = Notification.Name("salari")
        
        // Stop listening notification
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil);
    }
    
    
    @objc func reload(){
        tableView.reloadData()
        
        let salari = realm.objects(Salari.self)
        if salari.count > 0{

            
            if salari.first!.interacciones.count > 0{
                labelNoData.isHidden = true
                tableView.isHidden = false
            }
            else{
                labelNoData.isHidden = false
                tableView.isHidden = true
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension SalariViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 200))
        headerView.backgroundColor = Constants.Colors.BackgroundColor
        let topLabel = UILabel(frame: CGRect(x: 0, y: 20, width: tableView.bounds.size.width, height: 25))
        topLabel.font = UIFont(name: "Glegoo-Regular", size: 17)
        topLabel.textColor = .white
        topLabel.text = "Descompte contenidors"
        topLabel.textAlignment = .center
        headerView.addSubview(topLabel)

        let centerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 200))
        centerLabel.font = UIFont(name: "Glegoo-Regular", size: 45)
        centerLabel.textColor = .white
        let salari = realm.objects(Salari.self)
        if salari.count > 0{
            
            if let saldo = salari.first!.saldo_2{
                centerLabel.text = saldo
            }
        }
        centerLabel.textAlignment = .center
        headerView.addSubview(centerLabel)
        
        let bottomLabel = UILabel(frame: CGRect(x: 20, y: 160, width: tableView.bounds.size.width - 40, height: 25))
        bottomLabel.font = UIFont(name: "Glegoo-Regular", size: 17)
        bottomLabel.textColor = .white
        bottomLabel.text = "Actualització quadrimestral"
        bottomLabel.textAlignment = .right
       // headerView.addSubview(bottomLabel)
        
        let line = UIView(frame: CGRect(x: 0, y: 197, width: tableView.bounds.size.width, height: 3))
        line.backgroundColor = .white
        headerView.addSubview(line)
        return headerView
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let salari = realm.objects(Salari.self)
        if salari.count > 0{
            return salari.first!.interacciones.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let salari = realm.objects(Salari.self).first!
        let interaccion = salari.interacciones[indexPath.row]
        
        if selectedIndexes.contains(indexPath.row){
            if interaccion.actuaciones.count == 0{
                return 60
            }
            return CGFloat(60 + interaccion.actuaciones.count * 60)
            
        }
        return 60
        
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let salari = realm.objects(Salari.self).first!

        
        let cell: SalariItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! SalariItemTableViewCell
        // cell.backgroundColor = colors[indexPath.row]
        let interaccion = salari.interacciones[indexPath.row]
        cell.labelDiners.text = interaccion.cantidad
        cell.labelTitol.text = interaccion.fecha
        cell.backgroundColor = Constants.Colors.BackgroundColor
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        for sub in cell.contView.subviews{
            if sub.tag == 1001{
                sub.removeFromSuperview()
            }
        }
        
        if selectedIndexes.contains(indexPath.row) && interaccion.actuaciones.count > 0{
            cell.backgroundColor = UIColor(red: 190/255.0, green: 211/255.0, blue: 220/255.0, alpha: 1)
            
            var top = 60
            
            for act in interaccion.actuaciones{
                let sub = UIView(frame: CGRect(x: 25, y: top, width: Int(tableView.frame.size.width - 50), height: 60))
                sub.tag = 1001
                
                cell.contView.addSubview(sub)
                let dot = UIView(frame: CGRect(x: 0, y: 20, width: 20, height: 20))
                dot.layer.cornerRadius = 10
                dot.backgroundColor = .black
                sub.addSubview(dot)
                let label = UILabel(frame: CGRect(x: 35, y: 0, width: sub.frame.size.width - 70, height: 60))
                label.font = UIFont(name: "Glegoo-Regular", size: 15)
                label.numberOfLines = 2
                label.textColor = .black
                label.text = "Paper"

                if act.fraccion == Constants.Fraccions.Resta{
                    label.text = "Resta"
                    dot.backgroundColor = UIColor(red: 141/255.0, green: 141/255.0, blue: 141/255.0, alpha: 1)

                }
                else if act.fraccion == Constants.Fraccions.Organica{
                    label.text = "Orgànica"
                    dot.backgroundColor = UIColor(red: 109/255.0, green: 54/255.0, blue: 0/255.0, alpha: 1)
                }
                else if act.fraccion == Constants.Fraccions.Envases{
                    label.text = "Envasos"
                    dot.backgroundColor = UIColor(red: 191/255.0, green: 193/255.0, blue: 28/255.0, alpha: 1)

                }
                else if act.fraccion == Constants.Fraccions.Papel{
                    label.text = "Paper"
                    dot.backgroundColor = UIColor(red: 26/255.0, green: 211/255.0, blue: 193/255.0, alpha: 1)

                }
                else if act.fraccion == Constants.Fraccions.Vidrio{
                    label.text = "Vidre"
                    dot.backgroundColor = UIColor(red: 0/255.0, green: 137/255.0, blue: 10/255.0, alpha: 1)

                }
                sub.addSubview(label)
                
                let labelFecha = UILabel(frame: CGRect(x: 35, y: 0, width: sub.frame.size.width - 70, height: 60))
                labelFecha.font = UIFont(name: "Glegoo-Regular", size: 15)
                labelFecha.numberOfLines = 1
                labelFecha.textColor = .black
                labelFecha.text = act.timestamp
                labelFecha.textAlignment = .right
                sub.addSubview(labelFecha)
                
                top += 60
            }
        }
        else{
            cell.backgroundColor = Constants.Colors.TintColor
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectedIndexes.contains(indexPath.row){
            selectedIndexes.remove(at: selectedIndexes.index(of: indexPath.row)!)
        }
        else{
            selectedIndexes.append(indexPath.row)
        }
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}
