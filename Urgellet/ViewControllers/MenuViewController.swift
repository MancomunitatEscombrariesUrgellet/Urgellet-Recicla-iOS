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
import ReachabilitySwift
import APESuperHUD
import PDFReader
import SwiftEventBus

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserData {

    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var tableViewMenu: UITableView!
    @IBOutlet weak var tableViewOptions: UITableView!
    @IBOutlet weak var tableViewOptionsHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewOptionsBottom: NSLayoutConstraint!
    let realm = try! Realm()
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true

    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contratos = realm.objects(Contrato.self)
        
        tableViewOptionsHeight.constant = CGFloat(contratos.count * 120)
        tableViewOptionsBottom.constant = -CGFloat(contratos.count * 120)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.overlayView.addGestureRecognizer(tapGesture)
        
        SwiftEventBus.onMainThread(self, name: "updateBadge") { result in
            
            let count: String? = result?.object as? String
            self.tabBarController?.tabBar.items?[1].badgeValue = count
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tableViewOptions{
            return 120
        }
        else{
            switch indexPath.row {
            case 0:
                return 120
            default:
                return 160
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableViewOptions{
            return realm.objects(Contrato.self).count
        }
        else{
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableViewOptions{
            let cell = tableView.dequeueReusableCell(withIdentifier: "perfilHeaderCell", for: indexPath) as! PerfilHeaderTableViewCell
            let contrato = realm.objects(Contrato.self)[indexPath.row]
            cell.labelTitol.text = contrato.descripcion
            cell.labelSubtitol.text = "Contracte \(contrato.idVivienda)"
            
            return cell
        } else {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "perfilHeaderCell", for: indexPath) as! PerfilHeaderTableViewCell

                let predicate = NSPredicate(format: "idVivienda = %i", UserDefaults.standard.value(forKey: "idVivienda") as! Int)
                if let contrato = realm.objects(Contrato.self).filter(predicate).first{
                    cell.labelTitol.text = contrato.descripcion
                    cell.labelSubtitol.text = "Contracte \(contrato.idVivienda)"
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "perfilItemCell", for: indexPath) as! PerfilItemTableViewCell
                cell.labelTitol.text = "Recollida de residus"
                cell.labelSubtitol.text = "Calendari del servei"
                cell.icon.image = UIImage(named: "calendar")
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "perfilItemCell", for: indexPath) as! PerfilItemTableViewCell
                cell.labelTitol.text = "Descomptes"
                cell.labelSubtitol.text = "Historial de decomptes"
                cell.icon.image = UIImage(named: "folder")
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "perfilItemCell", for: indexPath) as! PerfilItemTableViewCell
                cell.labelTitol.text = "Coneix més"
                cell.labelSubtitol.text = "Atenció a l'usuari"
                cell.icon.image = UIImage(named: "question")
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "perfilHeaderCell", for: indexPath) as! PerfilHeaderTableViewCell
                return cell
            }
        }
    }
    
    @objc func tap(gesture: UITapGestureRecognizer) {

        let contratos = realm.objects(Contrato.self)
        tableViewOptionsBottom.constant = -CGFloat(contratos.count * 120)
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.overlayView.alpha = 0.0
        }, completion: {finished in })
        self.overlayView.isUserInteractionEnabled = false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableViewOptions{ // TODO FIX: WTF is this!!!!!!
            let contrato = realm.objects(Contrato.self)[indexPath.row]
            UserDefaults.standard.set(contrato.idVivienda, forKey: "idVivienda")
            let contratos = realm.objects(Contrato.self)
            tableViewOptionsBottom.constant = -CGFloat(contratos.count * 120)
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
                self.overlayView.alpha = 0.0
            }, completion: {finished in })
            tableViewMenu.reloadData()
            self.overlayView.isUserInteractionEnabled = false

            self.getUserData()
            self.getElementos()
            self.getUserDataDeixalleria()
            
        } else {
            switch indexPath.row {
            case 0:
                overlayView.alpha = 0.5
                tableViewOptionsBottom.constant = 0.0
                self.overlayView.isUserInteractionEnabled = true

                UIView.animate(withDuration: 0.3, animations: {
                    self.overlayView.alpha = 0.8
                    self.view.layoutIfNeeded()
                }, completion: {finished in })
            case 1:
                calidadesDocument()
            case 2:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let atencioVC = storyboard.instantiateViewController(withIdentifier: "HistorialDescomptesViewController") as! HistorialDescomptesViewController
                self.navigationController?.pushViewController(atencioVC, animated: true)
            case 3:
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let atencioVC = storyboard.instantiateViewController(withIdentifier: "AtencioViewController") as! AtencioViewController
                self.navigationController?.pushViewController(atencioVC, animated: true)
            default:
                break
            }
        }
    }
    
    
    func calidadesDocument(){
        
//        APESuperHUD.removeHUD(animated: true, presentingView: self.view, completion: { _ in
//            // Completed
//        })
        APESuperHUD.dismissAll(animated: true)
        let remotePDFDocumentURLPath = "https://admin.smartcity.link/pdf/recollida-mobles-voluminosos-urgellet.pdf"
        let remotePDFDocumentURL = URL(string: remotePDFDocumentURLPath)!
        let document = PDFDocument(url: remotePDFDocumentURL)!
        let readerController = PDFViewController.createNew(with: document)
        navigationController?.pushViewController(readerController, animated: true)
    }
}
