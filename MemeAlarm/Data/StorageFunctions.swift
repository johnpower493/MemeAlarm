//
//  StorageFunctions.swift
//  MemeAlarmEncoder
//
//  Created by JP on 4/9/21.
//

import Foundation

class StorageFunctions {
    
    static let savedSettings = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("SavedSettings.json")
    static let LocalSettings = Bundle.main.url(forResource: "LocalSettings", withExtension: "json")!
    
        //Update
    static func retrieveSettings() -> localMemeData {
        var url = savedSettings
        if !FileManager().fileExists(atPath: savedSettings.path) {
        url = LocalSettings
        }
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Unable to decode data")
        }
        guard let settingItems = try? decoder.decode(localMemeData.self, from: data) else {
            fatalError("Failed to decode JSON from data")
            
        }
       // print(settingItems)
        // print(LocalSettings)
        return settingItems
        
    }
    
    
    static func storeSettings(settings: localMemeData) {
        let encoder = JSONEncoder()
        guard let settingsJSONData = try? encoder.encode(settings) else {
            fatalError("Could not encode data")
        }
        let settingsJSON = String(data: settingsJSONData, encoding: .utf8)!
        do {
            try settingsJSON.write(to: savedSettings, atomically: true, encoding: .utf8)
        } catch {
            print("Could not save file to directory: \(error.localizedDescription)")
        }
    }
    
}
