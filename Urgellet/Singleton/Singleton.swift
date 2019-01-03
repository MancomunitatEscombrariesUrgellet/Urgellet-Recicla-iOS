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
import SwiftyTimer

class Singleton: NSObject {
    static let sharedInstance: Singleton = {
        let instance = Singleton()
        return instance
    }()
    
    var codesArray = [String]()
    var codesIncidenciesArray = [String]()
    var networkFailure: Bool = false
    
    func initTimer(){
        Timer.every(30.seconds) {
             (timer: Timer) in
            
            let realm = try! Realm()
            let incidPendents = realm.objects(IncidenciaPendent.self)
            let pendents = realm.objects(Pendent.self)
            if (incidPendents.count == 0 && pendents.count == 0) || self.networkFailure == true {
                timer.invalidate()
            } else {
                if (pendents.count > 0) {
                    self.sendPendents()
                }
                if (incidPendents.count > 0) {
                    self.sendIncidenciesPendents()
                }
            }
        }
    }
    
    func sendIncidenciesPendents(){
        let realm = try! Realm()
        let pendents = realm.objects(IncidenciaPendent.self)
        let pendent = pendents.first!
        
        if pendent.picture != nil{
            
            let user = realm.objects(User.self)
            
            if(user.count > 0){
                
                //TODO: create IncidenciaPendent Object and send to server and delete it on success
            }
        }
    }
    
    func sendPendents(){
        
        let realm = try! Realm()
        let pendents = realm.objects(Pendent.self)
        let pendent = pendents.first!
       
        //TODO: create Pendent Object and send to server and delete it on success
        
    }
}
