//
//  ContentView.swift
//  testClosetApp
//
//  Created by Meredith Kuhler on 11/14/23.
//

import SwiftUI
import CoreData

// =================== Content View =================== //
struct ContentView: View {
    // - variables
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var closet = ClosetManager()
    
    @FetchRequest(entity: User.entity(), sortDescriptors: [], animation: .default)
    private var users: FetchedResults<User>
    
    // - body
    var body: some View {
        VStack {
            if users.count > 0 { HomePageView(dat: closet) }
            else { EditUserInfoView() }
        }
    }
}

// =================== Global View Functions =================== //
func makeImage(data: Data?) -> some View { // create image given img data
    var output = Image(systemName: "photo").resizable().aspectRatio(contentMode: .fit)
    if data != nil
    {
        if let img = UIImage(data: data ?? Data())
        { output = Image(uiImage: img).resizable().aspectRatio(contentMode: .fit) }
    }
    return output
}
func displayUser(n: String, a:Int16) -> some View { // display user name and age
    return Section(header:Text("User Profile")) {
        HStack {
            Text("Name:").bold()
            Spacer()
            Text(n)
        }
        HStack {
            Text("Age:").bold()
            Spacer()
            Text("\(a)")
        }
    }
}

// =================== Preview =================== //
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var dat = ClosetManager()
        ContentView(closet: dat).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
