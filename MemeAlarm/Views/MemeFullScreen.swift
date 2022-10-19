//
//  MemeFullScreen.swift
//  MemeAlarm
//
//  Created by Gabriel Davila on 23/8/21.
//
//

import SwiftUI

struct MemeFullScreen: View {
    
    @EnvironmentObject var model: AlarmModel
    
    //image to display
    var memeImage:String
    var memeImages:[String]?
    @State var memeIndexSelected:Int
    
    @State private var saveMemeImage: Image?
    
    var body: some View {
        
        if memeImage != "" {
            ZStack {
                
                Rectangle()
                    .foregroundColor(.black)
                    .ignoresSafeArea()
                
                URLImage(url: memeImage, allowZoom: true)
                    .contextMenu{
                        Button("Save to Photos") {
                            model.saveImage(saveImageName: memeImage)
                        }
                    }
            }
        }
        else if memeImages != nil && memeImage == "" {
            ZStack {
                
                Rectangle()
                    .foregroundColor(.black)
                    .ignoresSafeArea()
                
                if let memeImages = memeImages {
                    GeometryReader { proxy in
                        TabView (selection: $memeIndexSelected) {
                            ForEach (0..<memeImages.count, id: \.self) {index in
                                URLImage(url: memeImages[index], allowZoom: true)
                                    .tag(index)
                                    .contextMenu{
                                        Button("Save to Photos"){
                                            model.saveImage(saveImageName: memeImages[index])
                                        }
                                    }
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                }
            }
            
        }
        else {
            Text("No Images selected. Unknown Error")
            
        }
    }

    
}


