//
//  ClosetManager.swift
//  testClosetApp
//
//  Created by Meredith Kuhler on 11/14/23.
//

import Foundation
import SwiftUI

struct listItem : Identifiable {
    let id:UUID
}

@MainActor class ClosetManager : ObservableObject { // _________________________ temp storage for closet
    // === variables
    @Published var isUserCreated = false
    
    @Published var tops:[listItem] = [] // ............... array of clothing items in view category 0 (shirt, dress)
    @Published var bottoms:[listItem] = [] //............. array of clothing items in view category 1 (pants, shorts, skirt)
    @Published var footwear:[listItem] = [] // ........... array of clothing items in view category 2 (shoes)
    
    @Published var displayTop:UUID = UUID()
    @Published var displayBottom:UUID = UUID()
    @Published var displayFootwear:UUID = UUID()
    
    func parseCoreData(tList:[UUID], bList:[UUID], fList:[UUID]) {
        // read fetched results to lists
        tops = [] ; for item in tList { tops.append(listItem(id:item)) }
        if tops.count > 0 { displayTop = tops[0].id }
        bottoms = [] ; for item in bList { bottoms.append(listItem(id:item)) }
        if bottoms.count > 0 { displayBottom = bottoms[0].id }
        footwear = [] ; for item in fList { footwear.append(listItem(id:item)) }
        if footwear.count > 0 { displayFootwear = footwear[0].id }
    }
    
    func findItem(current:UUID, type:Int) -> Int
    {
        var idx = 0
        if type == 0 {
            for (item) in tops
            { if current == item.id { return idx } ; idx += 1 }
        }
        if type == 1 {
            for (item) in bottoms
            { if current == item.id { return idx } ; idx += 1 }
        }
        if type == 2 {
            for (item) in footwear
            { if current == item.id { return idx } ; idx += 1 }
        }
        
        return -1
    }
    
    func getNext(current:UUID, type:Int)
    {
        let idx = findItem(current: current, type: type)
        
        if type == 0 { if idx + 1 < tops.count { displayTop = tops[idx + 1].id } }
        if type == 1 { if idx + 1 < bottoms.count { displayBottom = bottoms[idx + 1].id } }
        if type == 2 { if idx + 1 < footwear.count { displayFootwear =  footwear[idx + 1].id } }
    }
    
    func getPrev(current:UUID, type:Int)
    {
        let idx = findItem(current: current, type: type)
        
        if type == 0 { if idx > 0 { displayTop = tops[idx - 1].id } }
        if type == 1 { if idx > 0 { displayBottom = bottoms[idx - 1].id } }
        if type == 2 { if idx > 0 { displayFootwear = footwear[idx - 1].id } }
    }
    
}


@MainActor class UserManagement: ObservableObject {
    @Published var uName =  ""
    @Published var uAge:Int16 = 0
    @Published var uImage = UIImage()
    var doInit = true
    
    func setValues(n:String, a:Int16, i:Data) {
        uName =  n
        uAge  = a
        uImage = UIImage(data: i) ?? UIImage(systemName: "Photo") ?? UIImage()
        doInit = false
    }
}
