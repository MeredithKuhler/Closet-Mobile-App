//
//  Persistence.swift
//  testClosetApp
//
//  Created by Meredith Kuhler on 11/14/23.
//

import CoreData
import UIKit

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 1...3 {
            let newTop = Item(context: viewContext)  // make 3 tops
                newTop.id = UUID()
                newTop.image = UIImage(named: "Top\(i)")?.pngData()
                newTop.type = 0
            let newBott = Item(context: viewContext) // make 3 bottoms
                newBott.id = UUID()
                newBott.image = UIImage(named: "Bott\(i)")?.pngData()
                newBott.type = 1
            let newShoes = Item(context: viewContext)  // make 3 shoes
                newShoes.id = UUID()
                newShoes.image = UIImage(named: "Shoes\(i)")?.pngData()
                newShoes.type = 2
            /*if i == 1 { // make user
                let newUser = User(context: viewContext)
                newUser.name = "Meredith Kuhler"
                newUser.age = 21
                newUser.image = UIImage(named: "UserImage")?.pngData()
            }*/
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DigitalCloset")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
