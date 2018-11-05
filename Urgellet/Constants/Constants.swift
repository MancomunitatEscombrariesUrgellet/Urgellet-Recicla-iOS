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

struct Constants {
    
    struct Colors {
        static let BackgroundColor = UIColor(red: 0 / 255.0, green: 103 / 255.0, blue: 161 / 255.0, alpha: 1)
        static let TintColor = UIColor(red: 99 / 255.0, green: 199 / 255.0, blue: 204 / 255.0, alpha: 1)
        static let BarTintColor = UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 1)
        static let Act1 = UIColor(red: 0 / 255.0, green: 63 / 255.0, blue: 98 / 255.0, alpha: 1)
        static let Act2 = UIColor(red: 30 / 255.0, green: 65 / 255.0, blue: 98 / 255.0, alpha: 1)
        static let Act3 = UIColor(red: 1 / 255.0, green: 87 / 255.0, blue: 136 / 255.0, alpha: 1)
        static let Act4 = UIColor(red: 0 / 255.0, green: 111 / 255.0, blue: 174 / 255.0, alpha: 1)
        static let Act5 = UIColor(red: 0 / 255.0, green: 152 / 255.0, blue: 236 / 255.0, alpha: 1)
        static let Organica = UIColor(red: 231 / 255.0, green: 203 / 255.0, blue: 60 / 255.0, alpha: 1)
        static let Resta = UIColor(red: 197 / 255.0, green: 197 / 255.0, blue: 161 / 255.0, alpha: 1)
        static let Paper = UIColor(red: 26 / 255.0, green: 211 / 255.0, blue: 193 / 255.0, alpha: 1)
        static let Envasos = UIColor(red: 254 / 255.0, green: 254 / 255.0, blue: 58 / 255.0, alpha: 1)
        static let Vidre = UIColor(red: 38 / 255.0, green: 235 / 255.0, blue: 93 / 255.0, alpha: 1)
        static let Incidencies = UIColor(red: 239 / 255.0, green: 84 / 255.0, blue: 36 / 255.0, alpha: 1)

    }
    
    struct Fraccions {
        static let Resta = 1
        static let Organica = 4
        static let Envases = 15
        static let Papel = 27
        static let Vidrio = 33
    }

    }
