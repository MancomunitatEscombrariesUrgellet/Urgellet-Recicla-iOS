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

class IncidenciesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
//    class IncidenciesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let realm = try! Realm()
    let colors = [Constants.Colors.Act1,Constants.Colors.Act2,Constants.Colors.Act3,Constants.Colors.Act4,Constants.Colors.Act5,Constants.Colors.Act1 ]
    @IBOutlet weak var tableView: UITableView!
//    let imagePicker = UIImagePickerController()
    var elemento: Elemento?
    var nfcElemento: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Constants.Colors.BackgroundColor
        self.tableView.backgroundColor = Constants.Colors.BackgroundColor
        getActuaciones()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getActuaciones(){
        //TODO GET ACTUACIONES
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realm.objects(Actuacion.self).count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (realm.objects(Actuacion.self).count > 0){
            let screenSize = UIScreen.main.bounds
            let screenHeight = screenSize.height

            return (screenHeight - CGFloat(69)) / CGFloat(realm.objects(Actuacion.self).count)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: IncidenciesTableViewCell = tableView.dequeueReusableCell(withIdentifier: "incidenciaCell", for: indexPath) as! IncidenciesTableViewCell
        cell.backgroundColor = colors[indexPath.row]
        let actuacion = realm.objects(Actuacion.self)[indexPath.row]
        cell.labelIncidencia.text = actuacion.descripcion!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actuacion = realm.objects(Actuacion.self)[indexPath.row]
        print(actuacion.id)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let incidenciaFoto = storyboard.instantiateViewController(withIdentifier: "IncidenciaFotoViewController") as! IncidenciaFotoViewController
        incidenciaFoto.nfcElemento = nfcElemento
        incidenciaFoto.actuacion = actuacion
        if(actuacion.foto){
            incidenciaFoto.elemento = elemento
            self.navigationController?.pushViewController(incidenciaFoto, animated: true)
        }
        else{
            postActuacion(actuacion: actuacion)
        }
    }
    
    func postActuacion(actuacion: Actuacion){
        //TODO REGISTRAR
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
