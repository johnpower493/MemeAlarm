//
//  SoundControls.swift
//  MemeAlarm
//
//  Created by Gabriel Davila on 14/9/21.
//

import Foundation
import UIKit
import AVFoundation

class SoundControls: ObservableObject {
    
    //file manager to access local files
    let fileManager: FileManager = FileManager()
    
    //Directories to start looking for sounds
    //let rootSoundDirectories: [String] = ["/Library/Ringtones", "/System/Library/Audio/UISounds"]
    let bundleSoundDirectories:[String] = [Bundle.main.resourcePath!] //+ "/SupportingFiles"

    //directors where files are located
    @Published var directories: [NSMutableDictionary] = []
    
    @Published var allFiles:[soundFileNames] = [soundFileNames]()
    
    //directories that we pass the view
    var segueDirectory: NSDictionary!
    
    init () {
        
        for directory in bundleSoundDirectories {

            let newDirectory: NSMutableDictionary = [
                "path" : "\(directory)",
                "files" : []
            ]
            directories.append(newDirectory)
        }
        
        getDirectories()
        getSoundFiles()
        convertSoundsToArray()

    }
    
    func getDirectories() {
        for directory in bundleSoundDirectories {
            let directoryURL: URL = URL(fileURLWithPath: "\(directory)", isDirectory: true)
            do {
                var URLs: [URL]?
                URLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [URLResourceKey.isDirectoryKey], options: FileManager.DirectoryEnumerationOptions())
                
                var urlIsaDirectory: ObjCBool = ObjCBool(false)
                for url in URLs! {
                    fileManager.fileExists(atPath: url.path, isDirectory: &urlIsaDirectory)
                    if urlIsaDirectory.boolValue {
                        let directory: String = "\(url.relativePath)"
                        let newDirectory: NSMutableDictionary = [
                            "path" : "\(directory)",
                            "files" : []
                        ]
                        directories.append(newDirectory)
                    }
                }
            } catch {
                debugPrint("\(error)")
            }
        }
    }
    
    func getSoundFiles() {
        for directory in directories {
            let directoryURL: URL = URL(fileURLWithPath: directory.value(forKey: "path") as! String, isDirectory: true)
            
            do {
                var URLs: [URL]?
                URLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [URLResourceKey.isDirectoryKey], options: FileManager.DirectoryEnumerationOptions())
                var urlIsaDirectory: ObjCBool = ObjCBool(false)
                var soundPaths: [String] = []
                for url in URLs! {
                    fileManager.fileExists(atPath: url.path, isDirectory: &urlIsaDirectory)
                    if !urlIsaDirectory.boolValue {
                        soundPaths.append("\(url.lastPathComponent)")
                    }
                }
                directory["files"] = soundPaths
            } catch {
                debugPrint("\(error)")
            }
        }
    }
    
    func convertSoundsToArray () {
        
        var isDirectoryAdded = false
        
        for directoryVal in directories {
            let newSoundFile:soundFileNames = soundFileNames()
            newSoundFile.id = UUID.init()
            newSoundFile.path = directoryVal.value(forKey: "path") as? String ?? ""
            newSoundFile.name = directoryVal.value(forKey: "files") as? [String] ?? [String]()
            
            for index in 0..<newSoundFile.name.count {
                if newSoundFile.name[index].contains("mp3") == true && isDirectoryAdded == false {
                    allFiles.append(newSoundFile)
                    isDirectoryAdded = true
                    //return
                }
            }
        }
        
        var delIndex = 0
        
        repeat {
        
            if allFiles[0].name[delIndex].contains("mp3") != true {
            
                allFiles[0].name.remove(at: delIndex)
                
                //if i've removed an item in array, start the loop again
                delIndex = 0
            } else {
                
                //if mp3 not in name then increment delIndex
                delIndex += 1
            }
            
            
        } while delIndex < allFiles[0].name.count
        
        allFiles[0].name.sort()
        
    }

}


