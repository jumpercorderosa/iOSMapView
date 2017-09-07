//
//  TheaterAnnotation.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 06/09/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

//alfinete classe do componente (MKPointAnnotation)
//como vamos criar o seu proprio tipo de annotation, temos que criar nosas propria classe

import Foundation
import MapKit

//a classe herda de uma classe e implementa um protocolo
class TheaterAnnotation: NSObject, MKAnnotation {
    
    //propriedade de um annotation
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
