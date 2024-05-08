//
//  HomePageView.swift
//  DigitalCloset
//
//  Created by Meredith Kuhler on 11/18/23.
//

import SwiftUI
import CoreData

struct HomePageView: View {
    // ===== Variables ===== //
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var dat:ClosetManager
    @State private var action: Int? = 0
    
    let lightGray = Color(white: 0.8)
    let medGray = Color(white: 0.6)
    let darkGray = Color(white: 0.3)
    
    // ===== Body ===== //
    var body: some View {
        let user = fetchUser()
        
        NavigationStack {
            List {
                // --- User Profile
                userProfile(user: user).frame(height: 300)
                
                // --- Navigation Items
                NavigationLink(destination: OutfitBuilderView(closet: dat))
                { menuNavItem(icn: "cube.box", txt: "Outfit Mixer", subtxt: "Create new Outfits") }
                NavigationLink(destination: { ClothingItemsView() })
                { menuNavItem(icn: "magnifyingglass", txt: "Closet Items", subtxt: "Browse clothing items") }
                NavigationLink(destination: { AddNewItemView() })
                { menuNavItem(icn: "plus.app", txt: "Add New Item", subtxt: "Add new clothing item") }
                NavigationLink(destination: { WeatherReportView() })
                { menuNavItem(icn: "thermometer", txt: "Weather Report", subtxt: "Check weather at  current/search location") }
                NavigationLink(destination: { EditUserInfoView() })
                { menuNavItem(icn: "person", txt: "Edit Profile", subtxt: "Change profile info or picture") }
            }
        }
    }
    
    // ===== Make Sub-Views ===== //
    func menuNavItem(icn:String, txt:String, subtxt:String) -> some View {
        return HStack {
            Image(systemName: icn).font(.title).foregroundColor(medGray)
            VStack(alignment: .leading) {
                Text(txt).font(.title3).foregroundColor(darkGray)
                Text(subtxt).font(.caption).foregroundColor(medGray)
            }.frame(height: 50)
            Spacer()
        }
    }
    func userProfile(user:User) -> some View {
        return GeometryReader { geometry in VStack(alignment: .center) {
            // image
            ZStack {
                Circle().foregroundColor(lightGray)
                HStack { Spacer() ; makeImage(data: user.image).frame(width: 100) ; Spacer() }
            }.frame(width: 150)
            // name and age
            Text(user.name ?? "").font(.title3).foregroundColor(darkGray)
            Text("Age: \(user.age)").foregroundColor(medGray)
        }.frame(width: geometry.size.width) }
    }
    
    // ===== Fetch data ===== //
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
    private func fetchCount() -> Int { // by type
        var out = 0
        // - set up fetch request
        let fRequest: NSFetchRequest<Item> = Item.fetchRequest()
        // - run fetch and return
        do {
            let results = try viewContext.fetch(fRequest)
            out = results.count
        } catch let error { print(error.localizedDescription) }
        return out
    }
}

// ===== Preview ===== //
struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var dat = ClosetManager()
        HomePageView(dat: dat).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
