//
//  EditUserInfoView.swift
//  DigitalCloset
//
//  Created by Meredith Kuhler on 11/20/23.
//

import SwiftUI
import CoreData

struct EditUserInfoView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var user = UserManagement()
    
    let lightGray = Color(white: 0.8)
    let medGray = Color(white: 0.6)
    let darkGray = Color(white: 0.3)
    
    var body: some View {
        @State var userData:User? = fetchUser()
        @State var uName = user.uName
        @State var uAge = user.uAge
        
        VStack {
            Text("Edit Your Profile").font(.title).bold().padding()
            Form {
                HStack {
                    Spacer()
                    editUserImage(user: user)
                    Spacer()
                }
                Section("User Information") {
                    HStack {
                        Text("Name:").bold()
                        Spacer()
                        TextField("First Name", text: $user.uName)
                            .foregroundColor(darkGray).multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Age:").bold()
                        Picker("", selection: $user.uAge) {
                            ForEach(13..<100) { n in
                                Text("\(n)").tag(Int16(n))
                            }
                        }
                    }
                }
            }
            Button("Save and Continue") {
                deleteUser()
                addUser(n: user.uName, i: user.uImage.pngData()!, a: user.uAge)
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.black).buttonStyle(.bordered).padding()
        }.onAppear(perform: {
            if userData != nil {
                user.setValues(n: userData?.name ?? "", a: userData?.age ?? 13, i: userData?.image ?? Data())
            }
            
        })
    }
    
    private func fetchUser() -> User? {
        let fRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let users = try viewContext.fetch(fRequest)
            if users.count > 0 { return users[0] }
        } catch let error { print(error.localizedDescription) }
        return nil
    }
    private func parseUser(user:User) -> (n:String, i:Data, a:Int16)
    { return (user.name ?? "", user.image ?? Data(), user.age) }
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
    private func deleteUser() {
        if let user = fetchUser() {
            viewContext.delete(user)
            do { try viewContext.save() }
            catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// ===== Support Views ===== //
struct editUserImage: View {
    @ObservedObject var user:UserManagement
    @State private var isShowPhotoLibrary = false
    let lightGray = Color(white: 0.8)
    
    var body: some View {
        VStack {
            Button("+ Add/Change Picture") { isShowPhotoLibrary = true }
                .foregroundColor(.black).buttonStyle(.bordered)
            ZStack {
                Circle().foregroundColor(lightGray)
                HStack {
                    Spacer()
                    makeImage(data: user.uImage.pngData()).frame(width: 175, height: 175)
                    Spacer()
                }
            }.frame(width: 250)
        }.frame(height: 300).sheet(isPresented: $isShowPhotoLibrary)
            { ImagePicker(sourceType: .photoLibrary, selectedImage: $user.uImage) }
    }
}

struct EditUserInfoView_Previews: PreviewProvider {
    static var previews: some View {
        EditUserInfoView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
