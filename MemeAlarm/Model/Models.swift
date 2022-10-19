//
//  Models.swift
//  MemeAlarm
//
//  Created by Gabriel Davila on 23/8/21.
//

import Foundation

struct MemeAlarm: Codable, Identifiable {
    //local alarm - need to add disable/enable option
    
    var id: String = ""
    var alarmTime:String = ""
    var alarmDays:String = ""
    var label:String = ""
    var sound:String = ""
    var memeCategory:String = ""
    var enabledAlarm: Bool = true

}

struct memeObject: Codable, Identifiable{
    //meme object from online database
    
    var id: String = ""
    var imageURL:String = ""
    var memeCategory:String = ""

}

struct localMemeData: Codable, Identifiable {
    var id: String = ""
    var previousMeme: String = ""
    var tomorrowMeme: String = ""
    var backgroundColour: String = ""
    var allAlarms: [MemeAlarm] = [MemeAlarm]()
    var favouritedMemes: [String] = [String]()
    
}

class daysOfWeek: Identifiable, ObservableObject {
    @Published var id = UUID()
    @Published var name: String = ""
    @Published var isSelected:Bool = false
}

class soundFileNames: Identifiable, ObservableObject {
    var id = UUID()
    var name: [String] = [String]()
    var path: String = ""
}
