//
//  testClosetAppApp.swift
//  testClosetApp
//
//  Created by Meredith Kuhler on 11/14/23.
//

import SwiftUI

@main
struct DigitalClosetApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
