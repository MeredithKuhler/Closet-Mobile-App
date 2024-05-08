//
//  JsonWebMV.swift
//  DigitalCloset
//
//  Created by Meredith Kuhler on 11/21/23.
//

import Foundation
import CoreLocation
import MapKit

// Location Data Model
struct MapLocation: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

// json parsing
struct eqData : Decodable
{
    let location:location
    let current:current
}

struct location : Decodable {
    let name:String
    let lat:Double
    let lon:Double
}

struct current : Decodable
{
    let temp_f:Double
}

class jsonWebVM : ObservableObject
{
    var rawData:Data
    @Published var temp:Double = 0
    
    var urlAsString:String
    
    init()
    {
        rawData = Data()
        
        urlAsString = ""
    }
    
    func getJsonData(lat:String, lon:String) {
        
        urlAsString = "https://api.weatherapi.com/v1/current.json?key=1b92c6b976314b30910232511232111&q=\(lat),\(lon)&aqi=no"
        print(urlAsString)
        
        let url = URL(string: urlAsString)!
        let urlSession = URLSession.shared
        
        let jsonQuery = urlSession.dataTask(with: url, completionHandler: { data, response, error -> Void in
            if (error != nil) { print(error!.localizedDescription) }
            
            do {
                self.rawData = data!
                let decodedData = try JSONDecoder().decode(eqData.self, from: data!)
                DispatchQueue.main.async {
                    self.temp = decodedData.current.temp_f
                }
            } catch { print("error = \(error)") }
        })
        jsonQuery.resume()
    }
}

class LocationDataManager : NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            authorizationStatus = .authorizedWhenInUse
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
            manager.startUpdatingLocation()
            break
            
        case .restricted:
            authorizationStatus = .restricted
            break
            
        case .denied:
            authorizationStatus = .denied
            break
            
        case .notDetermined:
            authorizationStatus = .notDetermined
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            break
            
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        print(userLocation.coordinate.latitude)
        print(userLocation.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
    
    
}
