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

import Foundation
import RealmSwift
import SwiftEventBus

protocol UserData {
    func getUser()
    func getUserData()
    func getUserDataDeixalleria()
}

extension UserData {
    
    func getUser() {
        
        let realm = try! Realm()
        
        //TODO: sync from server User class save data on Realm Database
        //TODO: call self.getUserData() and self.getElementos() and self.getUserDataDeixalleria()
    }
    
    func getUserData() {
        
        let realm = try! Realm()

        //TODO: sync from server Salari class located on Salari.swift and save data on Realm Database
        
        var prevCountNoti = 0
        let prevNoti = realm.objects(Notificacion.self).count
        if (prevNoti > 0) {
            prevCountNoti = prevNoti
        }
        
        //TODO: sync from server Notificacion class array and save data on Realm Database
        //TODO update notification badge using SwiftEventBus.post("updateBadge", sender: String(badgeValue))
    }
    
    func getUserDataDeixalleria(){
        //TODO: sync from server SalariDeixalleria class located on Salari.swift and save data on Realm Database
    }
    
    func getElementos(){
        
        //TODO: sync from server Elemento class array and save data on Realm Database and call SwiftEventBus.post("syncSuccess") on success
    }
}
