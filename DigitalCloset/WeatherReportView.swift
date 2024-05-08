//
//  WeatherReportView.swift
//  DigitalCloset
//
//  Created by Meredith Kuhler on 11/21/23.
//

import SwiftUI
import CoreLocation
import MapKit

func r (_ places:Int, _ value:Double) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(value * divisor) / divisor
}

struct WeatherReportView: View {
    @StateObject var webVM = jsonWebVM()
    @StateObject var searchWebVM = jsonWebVM()
    @StateObject var locationDataManager = LocationDataManager()
    @State var coords = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @State var city = "Phoenix"
    @State var lon = 0.0
    @State var lat = 0.0
    
    var body: some View {
        Form {
            // --- today's local weather
            Section("Current Location") {
                switch locationDataManager.locationManager.authorizationStatus {
                case .authorizedWhenInUse:
                    Button("Get Weather") {
                        webVM.getJsonData(
                            lat:"\(locationDataManager.locationManager.location?.coordinate.latitude.description ?? "Error loading")",
                            lon:"\(locationDataManager.locationManager.location?.coordinate.longitude.description ?? "Error loading")")
                    }.buttonStyle(.borderless)
                    Text("Result: \(r(2,webVM.temp))")
                case .restricted, .denied:
                    Text("Current location data was restricted or denied.")
                case .notDetermined:
                    Text("Finding your location...")
                    ProgressView()
                default:
                    ProgressView()
                }
            }
            // --- search location weather
            Section("Search Location") {
                HStack { Text("City Name:") ; Spacer() ; TextField("", text: $city) }
                HStack {
                    Button("Get Weather") {
                        forwardGeocodeCoords(address: city)
                        searchWebVM.getJsonData(lat: "\(lat)", lon: "\(lon)")
                    }.buttonStyle(.borderless)
                    Spacer()
                    Text("Result: \(r(2,searchWebVM.temp))")
                }
                MapView(address: $city).frame(height: 300)
                //MapView(address: $city).frame(height: 300)
            }
        }
    }
    func forwardGeocodeCoords(address: String)
    {
        let geoCoder = CLGeocoder();
        geoCoder.geocodeAddressString(address, completionHandler: {(placemarks, error) in
            
            if error != nil {
                print("Geocode failed: \(error!.localizedDescription)")
            } else if placemarks!.count > 0 {
                let placemark = placemarks![0]
                let location = placemark.location
                let coords = location!.coordinate
                
                lat = coords.latitude
                lon = coords.longitude
            }
        })
    }
}

struct MapView: View {
    @State private static var defaultLocation = CLLocationCoordinate2D(
        latitude: 33.4255,
        longitude: -111.9400
    )

    // state property that represents the current map region
    @State private var region = MKCoordinateRegion(
        center: defaultLocation,
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    // state property that stores marker locations in current map region
    @State private var markers = [
        MapLocation(name: "Tempe", coordinate: defaultLocation)
    ]
    @Binding var address:String
    @State var lon: String = ""
    @State var lat: String = ""
    
    var body: some View {
        VStack {
            Button("Show on Map") { forwardGeocoding(addressStr: address) }
            Map(coordinateRegion: $region,
                interactionModes: .all,
                annotationItems: markers
            ){ location in
                MapMarker(coordinate: location.coordinate)
            }
        }
        .padding()
    }
    
    func forwardGeocoding(addressStr: String)
    {
        let addressString = addressStr
        CLGeocoder().geocodeAddressString(addressString, completionHandler: {(placemarks, error) in
            
            if error != nil {
                print("Geocode failed: \(error!.localizedDescription)")
            } else if placemarks!.count > 0 {
                let placemark = placemarks![0]
                let location = placemark.location
                let coords = location!.coordinate
                
                DispatchQueue.main.async
                {
                    region.center = coords
                    markers[0].name = placemark.locality!
                    markers[0].coordinate = coords
                }
            }
        })
    }
}

struct WeatherReportView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherReportView()
    }
}
