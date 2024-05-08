//
//  AddNewItemView.swift
//  DigitalCloset
//
//  Created by Meredith Kuhler on 11/21/23.
//

import SwiftUI

struct AddNewItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var image = UIImage()
    @State var type:Int16 = -1
    
    let darkGray = Color(white: 0.3)
    
    var body: some View {
        VStack {
            HStack {
                Text("Type:").bold()
                Picker("", selection: $type) {
                    Text("Top").tag(Int16(0))
                    Text("Bottom").tag(Int16(1))
                    Text("Footwear").tag(Int16(2))
                }.pickerStyle(.segmented)
            }.buttonStyle(.bordered)
            Spacer().frame(height: 60)
            addItemImage(image: $image)
            Spacer()
            Button("Add Item to Closet") {
                if type != -1
                { addItem(i: (image.pngData() ?? UIImage(systemName:"Photo")?.pngData())!, t: type) }
                presentationMode.wrappedValue.dismiss()
            }.buttonStyle(.bordered).foregroundColor(darkGray)
            Spacer()
        }.padding()
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
}

// ===== Support Views ===== //
struct addItemImage: View {
    @Binding var image:UIImage
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
                    makeImage(data: image.pngData()).frame(width: 175, height: 175)
                    Spacer()
                }
            }.frame(width: 250)
        }.frame(height: 300).sheet(isPresented: $isShowPhotoLibrary)
            { ImagePicker(sourceType: .photoLibrary, selectedImage: $image) }
    }
}

struct AddNewItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewItemView()
    }
}
