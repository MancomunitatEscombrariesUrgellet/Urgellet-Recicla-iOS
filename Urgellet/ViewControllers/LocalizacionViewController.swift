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
import MapKit
import RealmSwift

class LocalizacionViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var viewOrganica: UIView!
    @IBOutlet weak var viewResta: UIView!
    @IBOutlet weak var viewPaper: UIView!
    @IBOutlet weak var viewEnvasos: UIView!
    @IBOutlet weak var viewVidre: UIView!
    @IBOutlet weak var viewIncidencies: UIView!
    
    @IBOutlet weak var labelOrganica: UILabel!
    @IBOutlet weak var labelResta: UILabel!
    @IBOutlet weak var labelPaper: UILabel!
    @IBOutlet weak var labelEnvasos: UILabel!
    @IBOutlet weak var labelVidre: UILabel!
    @IBOutlet weak var labelIncidencies: UILabel!
    
    @IBOutlet weak var superViewOrganica: UIView!
    @IBOutlet weak var superViewResta: UIView!
    @IBOutlet weak var superViewPaper: UIView!
    @IBOutlet weak var superViewEnvasos: UIView!
    @IBOutlet weak var superViewVidre: UIView!
    @IBOutlet weak var superViewIncidencies: UIView!
    
    @IBOutlet weak var disabledViewOrganica: UIView!
    @IBOutlet weak var disabledViewResta: UIView!
    @IBOutlet weak var disabledViewPaper: UIView!
    @IBOutlet weak var disabledViewEnvasos: UIView!
    @IBOutlet weak var disabledViewVidre: UIView!
    @IBOutlet weak var disabledViewIncidencies: UIView!
    
    @IBOutlet weak var buttonReciclar: UIButton!

    var organicaSelected = false
    var restaSelected = false
    var paperSelected = false
    var envasosSelected = false
    var vidreSelected = false
    var incidenciesSelected = false


    var elementosSeleccionados = [Elemento]()
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonReciclar.isHidden = true
        
        self.view.backgroundColor = Constants.Colors.BackgroundColor
        buttonReciclar.backgroundColor = Constants.Colors.TintColor
        viewOrganica.backgroundColor = Constants.Colors.Organica
        viewResta.backgroundColor = Constants.Colors.Resta
        viewPaper.backgroundColor = Constants.Colors.Paper
        viewEnvasos.backgroundColor = Constants.Colors.Envasos
        viewVidre.backgroundColor = Constants.Colors.Vidre
        viewIncidencies.backgroundColor = Constants.Colors.Incidencies

        labelOrganica.text = NSLocalizedString("Orgànica", comment: "Orgànica")
        labelResta.text = NSLocalizedString("Resta", comment: "Resta")
        labelPaper.text = NSLocalizedString("Paper", comment: "Paper")
        labelEnvasos.text = NSLocalizedString("Envasos", comment: "Envasos")
        labelVidre.text = NSLocalizedString("Vidre", comment: "Vidre")
        labelIncidencies.text = NSLocalizedString("Incidencies", comment: "Incidencies")

        superViewOrganica.backgroundColor = Constants.Colors.BackgroundColor
        superViewResta.backgroundColor = Constants.Colors.BackgroundColor
        superViewPaper.backgroundColor = Constants.Colors.BackgroundColor
        superViewEnvasos.backgroundColor = Constants.Colors.BackgroundColor
        superViewVidre.backgroundColor = Constants.Colors.BackgroundColor
        superViewIncidencies.backgroundColor = Constants.Colors.BackgroundColor

        let tapGestureOrganica = UITapGestureRecognizer(target: self, action: #selector(self.tapOrganica(_:)))
        viewOrganica.addGestureRecognizer(tapGestureOrganica)

        let tapGestureResta = UITapGestureRecognizer(target: self, action: #selector(self.tapResta(_:)))
        viewResta.addGestureRecognizer(tapGestureResta)
        
        let tapGesturePaper = UITapGestureRecognizer(target: self, action: #selector(self.tapPaper(_:)))
        viewPaper.addGestureRecognizer(tapGesturePaper)

        let tapGestureEnvasos = UITapGestureRecognizer(target: self, action: #selector(self.tapEnvasos(_:)))
        viewEnvasos.addGestureRecognizer(tapGestureEnvasos)

        let tapGestureVidre = UITapGestureRecognizer(target: self, action: #selector(self.tapVidre(_:)))
        viewVidre.addGestureRecognizer(tapGestureVidre)

        let tapGestureIncidencies = UITapGestureRecognizer(target: self, action: #selector(self.tapIncidencies(_:)))
        viewIncidencies.addGestureRecognizer(tapGestureIncidencies)

        buttonReciclar.setTitle(NSLocalizedString("Reciclar", comment: "Reciclar"), for: .normal)

        mapView.userTrackingMode = .follow
        
        

    }


    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        checkNearContainers()
    }
    
    func checkNearContainers(){
        
        let elementos = realm.objects(Elemento.self)
        var distance = Float.greatestFiniteMagnitude
        
        var selectedElemento: Elemento?
        
        for elemento in elementos{
            if let lat = elemento.latitud, let lon = elemento.longitud, let douLat = Double(lat), let douLon = Double(lon){
                let loc = CLLocationCoordinate2DMake(douLat, douLon)
                print(loc)
                let from = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
                let to = CLLocation(latitude: (LocationManager.sharedInstance.locValue?.latitude)!, longitude: (LocationManager.sharedInstance.locValue?.longitude)!)
                
                let distanceInMeters = from.distance(from: to) // result is in meters
                print(distanceInMeters)
                if(Float(distanceInMeters) < distance && distanceInMeters < 50){
                    distance = Float(distanceInMeters)
                    selectedElemento = elemento
                }

            }
           
        }
        
        if let selectedElemento = selectedElemento{
            print(selectedElemento)
            let ubi = selectedElemento.idUbicacion
            let elementos = realm.objects(Elemento.self).filter("idUbicacion = %i", ubi)
            elementosSeleccionados = Array(elementos)
        }
        else{
            elementosSeleccionados = [Elemento]()
        }
        
        configViews()
    }
    
    func configViews(){
        disabledViewOrganica.isHidden = false
        disabledViewPaper.isHidden = false
        disabledViewResta.isHidden = false
        disabledViewEnvasos.isHidden = false
        disabledViewVidre.isHidden = false
        disabledViewIncidencies.isHidden = false
        buttonReciclar.isHidden = true

        if(organicaSelected && elementosSeleccionados.filter(){ $0.fraccion.value! == Constants.Fraccions.Organica}.count == 0){
            organicaSelected = false
            superViewOrganica.isHidden = true
        }
        
        if(restaSelected && elementosSeleccionados.filter(){ $0.fraccion.value! == Constants.Fraccions.Resta}.count == 0){
            restaSelected = false
            superViewResta.isHidden = true
        }
        
        if(paperSelected && elementosSeleccionados.filter(){ $0.fraccion.value! == Constants.Fraccions.Papel}.count == 0){
            paperSelected = false
            superViewPaper.isHidden = true
        }
        
        if(envasosSelected && elementosSeleccionados.filter(){ $0.fraccion.value! == Constants.Fraccions.Envases}.count == 0){
            envasosSelected = false
            superViewEnvasos.isHidden = true
        }
        
        if(vidreSelected && elementosSeleccionados.filter(){ $0.fraccion.value! == Constants.Fraccions.Vidrio}.count == 0){
            vidreSelected = false
            superViewVidre.isHidden = true
        }
        
        for elemento in elementosSeleccionados{
            switch elemento.fraccion.value! {
            case Constants.Fraccions.Organica:
                disabledViewOrganica.isHidden = true
            case Constants.Fraccions.Envases:
                disabledViewEnvasos.isHidden = true
            case Constants.Fraccions.Papel:
                disabledViewPaper.isHidden = true
            case Constants.Fraccions.Vidrio:
                disabledViewVidre.isHidden = true
            case Constants.Fraccions.Resta:
                disabledViewResta.isHidden = true
            default:
                break
            }
        }
        
        if(!organicaSelected && !restaSelected && !paperSelected && !envasosSelected && !vidreSelected && !incidenciesSelected){
            buttonReciclar.isHidden = true
        }
        else{
            buttonReciclar.isHidden = false
        }
    }
    
    @objc func tapOrganica(_ sender: UITapGestureRecognizer) {
        if(!organicaSelected){
            organicaSelected = true
            superViewOrganica.isHidden = false
        }
        else{
            organicaSelected = false
            superViewOrganica.isHidden = true
        }
        
        if(!organicaSelected && !restaSelected && !paperSelected && !envasosSelected && !vidreSelected && !incidenciesSelected){
            buttonReciclar.isHidden = true
        }
        else{
            buttonReciclar.isHidden = false
        }
    }
    
    @objc func tapResta(_ sender: UITapGestureRecognizer) {
        if(!restaSelected){
            restaSelected = true
            superViewResta.isHidden = false
        }
        else{
            restaSelected = false
            superViewResta.isHidden = true
        }
        
        if(!organicaSelected && !restaSelected && !paperSelected && !envasosSelected && !vidreSelected && !incidenciesSelected){
            buttonReciclar.isHidden = true
        }
        else{
            buttonReciclar.isHidden = false
        }
    }
    
    @objc func tapPaper(_ sender: UITapGestureRecognizer) {
        if(!paperSelected){
            paperSelected = true
            superViewPaper.isHidden = false
        }
        else{
            paperSelected = false
            superViewPaper.isHidden = true
        }
        
        if(!organicaSelected && !restaSelected && !paperSelected && !envasosSelected && !vidreSelected && !incidenciesSelected){
            buttonReciclar.isHidden = true
        }
        else{
            buttonReciclar.isHidden = false
        }
    }
    
    @objc func tapEnvasos(_ sender: UITapGestureRecognizer) {
        if(!envasosSelected){
            envasosSelected = true
            superViewEnvasos.isHidden = false
        }
        else{
            envasosSelected = false
            superViewEnvasos.isHidden = true
        }
        
        if(!organicaSelected && !restaSelected && !paperSelected && !envasosSelected && !vidreSelected && !incidenciesSelected){
            buttonReciclar.isHidden = true
        }
        else{
            buttonReciclar.isHidden = false
        }
    }
    
    @objc func tapVidre(_ sender: UITapGestureRecognizer) {
        if(!vidreSelected){
            vidreSelected = true
            superViewVidre.isHidden = false
        }
        else{
            vidreSelected = false
            superViewVidre.isHidden = true
        }
        
        if(!organicaSelected && !restaSelected && !paperSelected && !envasosSelected && !vidreSelected && !incidenciesSelected){
            buttonReciclar.isHidden = true
        }
        else{
            buttonReciclar.isHidden = false
        }
    }
    
    @objc func tapIncidencies(_ sender: UITapGestureRecognizer) {
        if(!incidenciesSelected){
            incidenciesSelected = true
            superViewIncidencies.isHidden = false
        }
        else{
            incidenciesSelected = false
            superViewIncidencies.isHidden = true
        }
        
        if(!organicaSelected && !restaSelected && !paperSelected && !envasosSelected && !vidreSelected && !incidenciesSelected){
            buttonReciclar.isHidden = true
        }
        else{
            buttonReciclar.isHidden = false
        }
    }
    
    @IBAction func reciclar(_ sender: Any) {
        
        if(organicaSelected && elementosSeleccionados.filter(){ $0.fraccion.value! == Constants.Fraccions.Organica}.count > 0){
            let elemento = elementosSeleccionados.filter(){ $0.fraccion.value! == Constants.Fraccions.Organica}.first!
            postRegistrar(elemento: elemento)
        }
        
    }
    
    func postRegistrar(elemento: Elemento){
        var params = [String: AnyObject]()
        
        params["idActuacion"] = elemento.fraccion.value as AnyObject?
        params["idElemento"] = [elemento.id] as AnyObject?
        params["modo"] = 3 as AnyObject?
        params["timestamp"] = Date().timeIntervalSince1970 as AnyObject?
        params["idVivienda"] = UserDefaults.standard.value(forKey: "idVivienda") as AnyObject?

        let user = realm.objects(User.self)
        if user.count > 0{
            params["idActuacion"] = "\(user.first!.registradoAct)" as AnyObject?
        }
        
        if(LocationManager.sharedInstance.locValue != nil){
            params["latitud"] = LocationManager.sharedInstance.locValue?.latitude as AnyObject?
            params["longitud"] = LocationManager.sharedInstance.locValue?.longitude as AnyObject?
            
        }
        
        print(params)
        
        //TODO REGISTRAR
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
