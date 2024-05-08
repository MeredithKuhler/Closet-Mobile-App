//
//  OutfitBuilderView.swift
//  testClosetApp
//
//  Created by Meredith Kuhler on 11/15/23.
//

import SwiftUI
import CoreData

struct BrowserView : View {
    @ObservedObject var closet:ClosetManager
    let data:Item
    let type:Int
    
    var body : some View {
        HStack {
            Button("Prev", action: { closet.getPrev(current: data.id!, type: type) })
                .buttonStyle(BorderlessButtonStyle())
            Spacer()
            if let img = data.image
                { makeImage(data: img).frame(maxWidth: 150) }
            Spacer()
            Button("Next", action:{ closet.getNext(current: data.id!, type: type) })
                .buttonStyle(BorderlessButtonStyle())
        }.frame(height: 140)
    }
}

struct WeatherView : View {
    @StateObject var webVM = jsonWebVM()
    @StateObject var locationDataManager = LocationDataManager()
    
    @State var lon = ""
    @State var lat = ""
    
    var body : some View {
        switch locationDataManager.locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            Text("Your current location is:")
            Text("Latitude: \(locationDataManager.locationManager.location?.coordinate.latitude.description ?? "Error loading")")
            Text("Longitude: \(locationDataManager.locationManager.location?.coordinate.longitude.description ?? "Error loading")")
        case .restricted, .denied:
            Text("Current location data was restricted or denied.")
        case .notDetermined:
            Text("Finding your location...")
            ProgressView()
        default:
            ProgressView()
        }
        /*VStack {
            switch locationDataManager.locationManager.authorizationStatus {
            case .authorizedWhenInUse:
                HStack {
                    Button("Get Today's Weather") {
                        webVM.getJsonData(
                            lat:"\(locationDataManager.locationManager.location?.coordinate.latitude.description ?? "Error loading")",
                            lon:"\(locationDataManager.locationManager.location?.coordinate.longitude.description ?? "Error loading")")
                    }.buttonStyle(.borderless)
                    Text("Result: \(webVM.temp)")
                }
            case .restricted, .denied:
                Text("Current location data was restricted or denied.")
            case .notDetermined:        // Authorization not determined yet.
                Text("Finding your location...")
                ProgressView()
            default:
                ProgressView()
            }
        }*/
    }
}

struct OutfitBuilderView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var closet:ClosetManager
    
    @StateObject var webVM = jsonWebVM()
    @StateObject var locationDataManager = LocationDataManager()
    @State var lon = ""
    @State var lat = ""
    
    var body: some View {
        let user = fetchUser()
        @State var dTop = closet.displayTop
        @State var dBottom = closet.displayBottom
        @State var dFootwear = closet.displayFootwear
        
        Form {
            // --- today's weather
            VStack {
                switch locationDataManager.locationManager.authorizationStatus {
                case .authorizedWhenInUse:
                    Button("Get Today's Weather") {
                        webVM.getJsonData(
                            lat:"\(locationDataManager.locationManager.location?.coordinate.latitude.description ?? "Error loading")",
                            lon:"\(locationDataManager.locationManager.location?.coordinate.longitude.description ?? "Error loading")")
                    }.buttonStyle(.borderless)
                    Text("Result: \(webVM.temp)")
                case .restricted, .denied:
                    Text("Current location data was restricted or denied.")
                case .notDetermined:
                    Text("Finding your location...")
                    ProgressView()
                default:
                    ProgressView()
                }
            }
            // --- closet view
            Section ("")
            {   // - headshot
                HStack
                { Spacer() ; makeImage(data: user.image).frame(height: 95) ; Spacer()}
                // - tops browser
                if let dTopData = fetchItemData(id: dTop,type: 0)
                { BrowserView(closet: closet, data: dTopData, type: 0) }
                else { Text("There are no tops in your closet").foregroundColor(.red) }
                // - bottoms browser
                if let dBottomData = fetchItemData(id: dBottom,type: 1)
                { BrowserView(closet: closet, data: dBottomData, type: 1) }
                else { Text("There are no botttoms in your closet").foregroundColor(.red) }
                // - footwear browser
                if let dFootwearData = fetchItemData(id: dFootwear,type: 2)
                { BrowserView(closet: closet, data: dFootwearData, type: 2) }
                else { Text("There are no shoes in your closet").foregroundColor(.red) }
            }
        }.onAppear(perform: {
            closet.parseCoreData(tList: fetchByType(0), bList: fetchByType(1), fList: fetchByType(2))
        })
    }
    
    // ===== Fetch closet data ===== //
    private func fetchByType(_ type:Int16) -> [UUID] { // by type
        var out:[UUID] = []
        // - set up fetch request
        let fRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fRequest.predicate = NSPredicate(format: "type = %@", argumentArray: [type])
        // - run fetch and return
        do {
            let results = try viewContext.fetch(fRequest)
            for item in results {
                out.append(item.id!)
            }
        } catch let error { print(error.localizedDescription) }
        return out
    }
    private func fetchItemData(id:UUID, type:Int16) -> Item? { // by id
        var out:Item?
        let fRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fRequest.entity = Item.entity()
        fRequest.predicate = NSPredicate(format: "type = %@", argumentArray: [type])
        do {
            let results = try viewContext.fetch(fRequest)
            for i in 0..<results.count {
                if results[i].id! == id { out = results[i] }
            }
        } catch let error { print(error.localizedDescription) }
        
        return out
    }
    // ===== Fetch user data ===== //
    func fetchUser() -> User
    {
        var out = User()
        let fRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let users = try viewContext.fetch(fRequest)
            out = users[0]
        } catch let error { print(error.localizedDescription) }
        return out
    }
}

// ===== Preview ===== //
struct OutfitBuilderView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var dat = ClosetManager()
        OutfitBuilderView(closet:dat).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
