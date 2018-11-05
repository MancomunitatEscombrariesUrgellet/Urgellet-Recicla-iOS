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

import RealmSwift
import SwiftEventBus

class UserDataAccess {
    
    static func saveUser(token: String, refreshToken : String) -> User {
        
        let realm = try! Realm()
    
        let user = self.getUser()
        if user != nil {
            try! realm.write {
                user?.token = token
                user?.refresh_token = refreshToken
                user?.loggedOut = false
                realm.add(user!, update: true)
            }
        }
        
        return user!
    }
    
    static func savePrivacy() {
        let realm = try! Realm()
        let user = self.getUser()
        if user != nil {
            try! realm.write {
                user?.privacyViewed = true
                realm.add(user!, update: true)
            }
        }
        
    }
    
    static func logoutUser() {
        let realm = try! Realm()
        let user = self.getUser()
        if user != nil {
            try! realm.write {
                user?.loggedOut = true
                realm.add(user!, update: true)
                SwiftEventBus.post("loggedOut")
            }
        }
        
//        print(user)
    }
    
    static func getUser() -> User? {
        let realm = try! Realm()
        let user: User? = realm.objects(User.self).first
        return user
    }
}
