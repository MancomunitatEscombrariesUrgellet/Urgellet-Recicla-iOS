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

class NotificacionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!

    let realm = try! Realm()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarItem.title = ""
        tabBarItem.imageInsets = UIEdgeInsets(top: 9, left: 0, bottom: -9, right: 0)

        
        self.view.backgroundColor = Constants.Colors.BackgroundColor
        tableView.backgroundColor = Constants.Colors.BackgroundColor
        tableView.separatorColor = Constants.Colors.BackgroundColor
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140

        noDataLabel.text = NSLocalizedString("No tens notificacions", comment: "No tens notificacions")
        noDataLabel.textColor = Constants.Colors.TintColor
        
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tableView.tableFooterView = footer

        let notificationName = Notification.Name("notificaciones")
        
        let notificaciones = realm.objects(Notificacion.self)
        if notificaciones.count > 0{
            tableView.isHidden = false
            noDataLabel.isHidden   = true

        }
        else{
            tableView.isHidden = true
            noDataLabel.isHidden   = false
        }

        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: notificationName, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.items?[1].badgeValue = nil   // this will add "1" badge to your fifth tab bar item
        
        //TODO GET NOTIFICATIONS
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let notificationName = Notification.Name("salari")
        
        // Stop listening notification
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil);
    }

    @objc func reload(){
        let notificaciones = realm.objects(Notificacion.self)
        if notificaciones.count > 0{
            tableView.isHidden = false
            noDataLabel.isHidden   = true
            
        }
        else{
            tableView.isHidden = true
            noDataLabel.isHidden   = false
        }
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let noti = realm.objects(Notificacion.self)
        return noti.count

    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NotificacioTableViewCell = tableView.dequeueReusableCell(withIdentifier: "notificacioCell", for: indexPath) as! NotificacioTableViewCell
        cell.backgroundColor = Constants.Colors.TintColor

        let notificacion = realm.objects(Notificacion.self)[indexPath.row]

        
        cell.labelTitol.text = notificacion.mensaje
        cell.labelData.text = notificacion.fecha

        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero

        return cell
    }
}
