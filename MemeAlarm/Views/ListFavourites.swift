//
//  ListFavourites.swift
//  MemeAlarm
//
//  Created by Gabriel Davila on 22/8/21.
//

import SwiftUI

struct ListFavourites: View {
    
    @EnvironmentObject var model: AlarmModel
    
    var body: some View {
        NavigationView {
            ZStack {
                
                LinearGradient(gradient: Gradient(colors: [Color(red: 250/255, green: 229/255, blue: 149/255), Color.white]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack {
                    
                    Image("logo-inline")
                        .resizable()
                        .frame(width: 350, height: 125)
                        .aspectRatio(contentMode: .fill)
                        .padding(.horizontal, 10)
                    
                    Text("Favourited Memes")
                        .font(.title)
                        .bold()
                        .foregroundColor(.black)
                    
                    ZStack {
                        
                        //card rectangle
                        HStack{
                            Spacer()
                            Rectangle()
                                .foregroundColor(.white)
                                .cornerRadius(40)
                                .padding(.horizontal, 20.0)
                                .shadow(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5), radius: 5, x: 5, y: 5)
                            Spacer()
                        }
                        ScrollView {
                            LazyVGrid (columns: [GridItem(.fixed(135)), GridItem(.fixed(135))], alignment: .center) {
                                if model.localMemeFile.favouritedMemes.count > 0 {
                                    ForEach (0..<model.localMemeFile.favouritedMemes.count, id: \.self) {index in
                                        
                                        NavigationLink (
                                            destination:
                                                //need to pass alarm details to go into edit alarm
                                            //MemeFullScreen(memeImage:  model.localMemeFile.favouritedMemes[index])
                                            MemeFullScreen(memeImage: "", memeImages: model.localMemeFile.favouritedMemes, memeIndexSelected: index)
                                            
                                            ,label: {
                                                URLImage(url: "\(model.localMemeFile.favouritedMemes[index])", allowZoom: false)
                                                    .scaledToFit()
                                                    .frame(width: 125, height: 125)
                                                    .padding(.vertical, 10)
                                            })
                                        .accentColor(.black)
                                        .contextMenu{
                                            Button("Save to Photos") {
                                                model.saveImage(saveImageName: model.localMemeFile.favouritedMemes[index])
                                            }
                                            Button("Remove from Favourites") {
                                                var removeIndex: Int = -1
                                                let currentFavouritedMeme = model.localMemeFile.favouritedMemes[index]
                                                for indexRemove in 0..<model.localMemeFile.favouritedMemes.count {
                                                    if model.localMemeFile.favouritedMemes[indexRemove] == currentFavouritedMeme {
                                                        removeIndex = indexRemove
                                                    }
                                                }
                                                if removeIndex != -1 {
                                                    model.localMemeFile.favouritedMemes.remove(at: removeIndex)
                                                    model.addMemeAlarm(writeDataFile: model.localMemeFile)
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                                else {
                                    
                                    Text("Make sure you star your favourite memes to save them here")
                                    
                                }
                            }
                            
                        }
                        
                    }
                    
                    Spacer()
                    
                }
                .navigationBarTitle(Text("Back"), displayMode: .inline).foregroundColor(.white)
                .navigationBarHidden(true)
                
                Spacer()
                
            }
            
        }
    }
}


