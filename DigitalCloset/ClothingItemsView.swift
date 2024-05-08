//
//  ClothingItemsView.swift
//  DigitalCloset
//
//  Created by Meredith Kuhler on 11/19/23.
//

import SwiftUI
import UIKit
import CoreData

struct ClothingItemsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @FetchRequest( entity: Item.entity(), sortDescriptors: [], animation: .default)
    private var items: FetchedResults<Item>
    
    var body:some View {
        NavigationView {
            List { // --- Tops
                Section("Tops") {
                    let tops = fetchByType(0)
                    ForEach(tops, id: \.self) { item in
                        let top = fetchItemData(id: item, type: 0)
                        HStack  {
                            makeImage(data: top?.image).frame(height: 60)
                            Spacer()
                            Button(action: {
                                        deleteItem(id: item)
                                        presentationMode.wrappedValue.dismiss() },
                                   label: {Image(systemName: "trash")}
                            ).foregroundColor(.red)
                        }
                    }
                } // --- Bottoms
                Section("Bottoms") {
                    let bottoms = fetchByType(1)
                    ForEach(bottoms, id: \.self) { item in
                        let bottom = fetchItemData(id: item, type: 1)
                        HStack  {
                            makeImage(data: bottom?.image).frame(height: 60)
                            Spacer()
                            Button(action: { deleteItem(id: item) ; presentationMode.wrappedValue.dismiss() },
                                   label: {Image(systemName: "trash")}
                            ).foregroundColor(.red)
                        }
                    }
                } // --- Footwear
                Section("Footwear") {
                    let footwear = fetchByType(2)
                    ForEach(footwear, id: \.self) { item in
                        let shoe = fetchItemData(id: item, type: 2)
                        HStack  {
                            makeImage(data: shoe?.image).frame(height: 60)
                            Spacer()
                            Button(action: { deleteItem(id: item) ; presentationMode.wrappedValue.dismiss() },
                                   label: {Image(systemName: "trash")}
                            ).foregroundColor(.red)
                        }
                    }
                }
            }
        }
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
        // - set up fetch request
        let fRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fRequest.entity = Item.entity()
        fRequest.predicate = NSPredicate(format: "type = %@", argumentArray: [type])
        // - run fetch and return
        do {
            let results = try viewContext.fetch(fRequest)
            for i in 0..<results.count {
                if results[i].id! == id { out = results[i] }
            }
        } catch let error { print(error.localizedDescription) }
        
        return out
    }
    // ===== Delete Item ===== //
    private func deleteItem(id:UUID) {
        withAnimation {
            for item in items {
                if item.id == id { viewContext.delete(item) }
            }
            do { try viewContext.save() }
            catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// ===== Preview ===== //
struct ClothingItemsView_Previews: PreviewProvider {
    static var previews: some View {
        ClothingItemsView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
