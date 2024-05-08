//
//  DataEntryTestingView.swift
//  testClosetApp
//
//  Created by Meredith Kuhler on 11/15/23.
//

import SwiftUI
import CoreData

struct DataEntryTestingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var dat:ClosetManager
    
    @FetchRequest( entity: Item.entity(), sortDescriptors: [], animation: .default)
    private var items: FetchedResults<Item>
    
    @FetchRequest(entity: User.entity(), sortDescriptors: [], animation: .default)
    private var users: FetchedResults<User>

    var body: some View {
        NavigationStack {
            List {
                // - List of data entries
                ForEach(items) { item in
                    Text("\(item.id!)")
                }
                ForEach(users) { user in
                    Text("\(user.name!)")
                }
            }.toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button( action: { addItem(i: Data(), t: 0) })
                    { Label("Add Item", systemImage: "plus.circle") }
                    Button ( action: { addUser(n: "Meredith Kuhler", i: Data(), a: 21) })
                    { Label("Add User", systemImage: "person.crop.circle.badge.plus") }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button ( action: { dat.isUserCreated = true})
                    { Text("Done") }
                }
            }
        }
    }

    private func addItem(i: Data, t: Int16) {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.id = UUID()
            newItem.image = i
            newItem.type = t

            do { try viewContext.save() }
            catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    private func addUser(n: String, i: Data, a: Int16) {
        withAnimation {
            let newItem = User(context: viewContext)
            newItem.name = n
            newItem.image = i
            newItem.age = a

            do { try viewContext.save() }
            catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do { try viewContext.save() }
            catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct DataEntryTestingView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var dat = ClosetManager()
        DataEntryTestingView(dat: dat).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
