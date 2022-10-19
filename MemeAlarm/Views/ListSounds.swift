//
//  ListSounds.swift
//  MemeAlarm
//
//  Created by Gabriel Davila on 14/9/21.
//

import SwiftUI
import AVFoundation

struct ListSounds: View {
    
    @Environment(\.presentationMode) var presentationMode2
    @EnvironmentObject var model: AlarmModel
    @EnvironmentObject var sounds: SoundControls
    @Binding var localSounds: String
    @State var prevSelectedSound: String = ""
    
    @State var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        VStack {
            
            Text("Sounds")
                .font(.title)
                .bold()
            
            Text("Currently Selected: \(localSounds)")
                .font(.caption)
            
            List {
                
                    ForEach (0..<sounds.allFiles[0].name.count) { index in
                        Button(action: {
                            //do code here
                            let filePathURL = URL(fileURLWithPath: String(sounds.allFiles[0].path + "/" + sounds.allFiles[0].name[index]))
                            do {
                                audioPlayer = try AVAudioPlayer(contentsOf: filePathURL)
                                audioPlayer?.play()
                                prevSelectedSound = localSounds
                                localSounds = String(sounds.allFiles[0].name[index].dropLast(4))
                            } catch {
                                print("ERROR")
                            }
                            
                        }, label: {
                            let soundsFileName = String(sounds.allFiles[0].name[index].dropLast(4))
                            HStack {
                                Text("\(soundsFileName)")
                                Spacer()
                            }
                        })
                    }
                
            }
            .listStyle(InsetListStyle())
            
            HStack {
                
                Spacer()
                
                Button("OK") {
                    //UPdate binding with text
                    self.presentationMode2.wrappedValue.dismiss()
                }
                
                Spacer()
                
                Button("Cancel") {
                    //undo changed code to previously selected
                    if prevSelectedSound != "" {
                        localSounds = prevSelectedSound
                    }
                    self.presentationMode2.wrappedValue.dismiss()
                }
                
                Spacer()
                
            }
            
        }
    }
}

