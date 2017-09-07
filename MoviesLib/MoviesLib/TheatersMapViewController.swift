//
//  TheatersMapViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 06/09/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit
import MapKit // se nao colocar o componente com o map no historyboard vai crashar

class TheatersMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    lazy var locationManager = CLLocationManager() // lazy so instancia quando precisar
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //qlqr dado pessoal do usuario tenho que pedir explicitamente a permissao
    //faco isso no Info.plist, seleciono o tipo de permissao e escrevo a mensagem
    
    
    //minha lista de objetos
    var theaters: [Theater] = []
    var theater: Theater!
    var currentElement: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(theaters.count)
        
        mapView.delegate = self
        searchBar.delegate = self
        
        loadXML()
        requestUserLocationAuthorization()
        
        

        // Do any additional setup after loading the view.
    }
    
    //vou solicitar autorazao para o usuario
    func requestUserLocationAuthorization() {
        ///mas antes verifique se o gps esta habilitado
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            
            //quanto maior a precisao, mais bateria eh utilizada
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            //obtem as localizacoes mesmo com o app em backgroud
            locationManager.allowsBackgroundLocationUpdates = true
            
            //da uma pausa na utilizacao do gsp caso o app nao esteja sendo usado por muito tempo
            locationManager.pausesLocationUpdatesAutomatically = true
            
            //verifico se tenho ou nao a autorizacao
            switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Usuario liberou a bagaca")
                case .denied:
                    print("Usuario negou o acesso a sua localizacao")
                case .notDetermined:
                    print("Ainda nao foi solicitada a autorizacao")
                    locationManager.requestWhenInUseAuthorization()
                default:
                    break
                //temos que autorizar o Location updates no background Mode capabilities
            }
        }
    }

    func addTheater() {
        
        //adiciono um annotation para cada item do meu array de theaters
        for theater in theaters {
            
            let coordinate = CLLocationCoordinate2D(latitude: theater.latitude, longitude: theater.longitude)
            let annotation = TheaterAnnotation(coordinate: coordinate)
            annotation.title = theater.name
            annotation.subtitle = theater.address
            
            //adiciono a anotation no mapView
            mapView.addAnnotation(annotation)
        }
        
        //da o zoom no map de acordo com as coordenadas existentes no vetor 
        mapView.showAnnotations(mapView.annotations, animated: true)
    
    }

    func loadXML() {
        if let xmlURL = Bundle.main.url(forResource: "theaters", withExtension: "xml"), let xmlParser = XMLParser(contentsOf: xmlURL) {

            //essa classe vai interpretar o parser do xml
            xmlParser.delegate = self
            
            // devolve tudo para o delegate
            xmlParser.parse()
        }
    }
    

    
    

}

//implementar os protocolos
extension TheatersMapViewController: XMLParserDelegate {

    //esse metodo eh chamado no inicio de um elemento, e ele devolve o nome do elemento que ele encontrou
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        //print(elementName)
        
        currentElement = elementName
        
        //a
        if elementName == "Theater" {
            theater = Theater()
        }
        
    }
    
    //devolve o conteudo do elemento
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //print(string)
        
        //desconsidera os caracteres em branco e \n
        let content = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        //faz o parse do XML
        if !content.isEmpty {
            switch currentElement {
            case "name":
                theater.name = content
            case "address":
                theater.address = content
            case "latitude":
                theater.latitude = Double(content)!
            case "longitude":
                theater.longitude = Double(content)!
            case "url":
                theater.url = content
            default:
                break
            }
        }
        
    }
    
    //Devolve o fim da tag
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        //print(elementName)
        
        if elementName == "Theater" {
            
            //appendei o objeto no vector
            theaters.append(theater)
        }
    }
    
    //identifica se finalizou o parse
    func parserDidEndDocument(_ parser: XMLParser) {
        addTheater()
    }
}

extension TheatersMapViewController: MKMapViewDelegate {
    //precisamos de um metodo que sempre chama o alfinete no mapa para ele nao pegar o default
    //ele retorna uma view que vamos personalizar
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView!
        
        //garanto que vou modificar as view de Theater e nao as outras do usuario
        if annotation is TheaterAnnotation {
            
            //pede uma annotation reutilizavel e passa um identificador, que neste caso eh a Theater
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Theater")
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Theater")
                annotationView.image = UIImage(named: "theaterIcon")
                annotationView.canShowCallout = true // mostra a descricao
            } else {
                //tem que limpar a annotation por ela ser reutilizavel
                annotationView.annotation = annotation
            }
            return annotationView
        }
        
        return annotationView
    }
    
}

extension TheatersMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
        default:
            break
        }
    }
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print(userLocation.location!.speed) //printo a latitude e longitude
        
        //o mapa vai para onde quer q ele va
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 500, 500)
        mapView.setRegion(region, animated: true)
    }
}

extension TheatersMapViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
       // searchBar.text
    }
}
