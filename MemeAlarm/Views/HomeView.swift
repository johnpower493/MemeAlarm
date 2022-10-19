//
//  NewAlarm.swift
//  MemeAlarm
//
//  Created by Gabriel Davila on 22/8/21.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var model: AlarmModel
    @EnvironmentObject var sounds: SoundControls
    
    @State var favouritedMeme = false
    @State var starSysImage = "heart"
    @State var starImageColor:Color = .black
    @State var isMemeShowing = false
    @State var isEditAlarmShowing = false
    @State var memeCategoryIndex = 0
    @State var updateView = false
    @State var alreadyAddedToFavourites = false
    @State var buttonText = "Add to Favourites"
    
    
    var body: some View {
        
        
        ZStack {
            
            LinearGradient(gradient: Gradient(colors: [Color(red: 250/255, green: 229/255, blue: 149/255), Color.white]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                
                //logo
                Image("logo-inline")
                    .resizable()
                    .frame(width: 350, height: 125)
                    .aspectRatio(contentMode: .fill)
                    .padding(.horizontal, 10)
                
                ZStack {
                    
                    //card rectangle
                    Rectangle()
                        .foregroundColor(.white)
                        .cornerRadius(40)
                        .padding(.all, 20.0)
                        .shadow(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5), radius: 5, x: 5, y: 5)
                    
                    VStack {
                        
                        Spacer()
                        
                        //top row, next alarm label + edit button (read from model file + static image to pass index)
                        HStack{
                            
                            //let textVal:String = (model.nextAlarmID == -1) ? : model.localMemeFile.allAlarms[model.nextAlarmID].label
                            
                            if model.nextAlarmID == -1 {
                                Text("Next Alarm - No alarms set")
                                    .bold()
                                    .padding(.leading, 40)
                                    .foregroundColor(.black)
                            }
                            else {
                                Text("Next Alarm - \(model.localMemeFile.allAlarms[model.nextAlarmID].label)")
                                    .bold()
                                    .padding(.leading, 40)
                                    .foregroundColor(.black)
                            }
                            Spacer()
                            
                            Button {
                                //code here
                                if model.localMemeFile.allAlarms.count > 0 && model.nextAlarmID != -1 {
                                    isEditAlarmShowing = true
                                }
                                model.refreshVariable = 1
                                
                            } label: {
                                Image(systemName: "pencil")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 40)
                                
                            }
                            .sheet(isPresented: $isEditAlarmShowing){
                                if model.nextAlarmID != -1 && model.localMemeFile.allAlarms.count > 0 {
                                    EditAlarm(updateView: $updateView, editMemeAlarm: model.localMemeFile.allAlarms[model.nextAlarmID], logoLocation: 10, localToggle: model.localMemeFile.allAlarms[model.nextAlarmID].enabledAlarm, localMemeCategory: model.localMemeFile.allAlarms[model.nextAlarmID].memeCategory, localAlarmDays: model.localMemeFile.allAlarms[model.nextAlarmID].alarmDays, localTimeDate: model.convertStringToDate(time: model.localMemeFile.allAlarms[model.nextAlarmID].alarmTime), localSound: model.localMemeFile.allAlarms[model.nextAlarmID].sound)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        //time section with days of next alarm (read from model file)
                        VStack {
                            
                            HStack {
                                Spacer()
                                
                                Text("Time: ")
                                    .bold()
                                    .foregroundColor(.black)
                                
                                Spacer()
                                if (model.localMemeFile.allAlarms.count > 0 && model.nextAlarmID == -1) { //there are alarms but they are all turned off
                                    Text("All alarms are off\nTurn one on to see it here")
                                        .foregroundColor(.black)
                                } else if (model.localMemeFile.allAlarms.count == 0) {
                                    Text("No Alarms set")
                                        .foregroundColor(.black)
                                } else {
                                    Text(model.convertStringToDate(time: model.localMemeFile.allAlarms[model.nextAlarmID].alarmTime), style: .time)
                                        .foregroundColor(.black)
                                }
                                Spacer()
                                
                            }
                            .padding(.bottom, 10)
                            
                            //create buttons for this
                            if model.localMemeFile.allAlarms.count > 0 || model.nextAlarmID != -1 {
                                //Text("MON TUE WED THU FRI SAT SUN")
                                DayCircles(selectedDays: $model.localMemeFile.allAlarms[model.nextAlarmID].alarmDays)
                                    .frame(width: 300, height: 50)
                                
                            }
                            else {
                                Text("")
                            }
                        }
                        
                        Spacer()
                        
                        //category of next alarm code (read from model files)
                        HStack {
                            Text("Category")
                                .bold()
                                .padding(.trailing, 25)
                                .foregroundColor(.black)
                            
                            if model.localMemeFile.allAlarms.count > 0 || model.nextAlarmID != -1 {
                                Text(model.localMemeFile.allAlarms[model.nextAlarmID].memeCategory)
                                    .foregroundColor(.black)
                            } else {
                                Text("")
                            }
                            
                        }
                        .padding(.bottom, 5)
                        
                        Spacer()
                        
                    }
                    
                }
                
                Text("Latest Meme")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)
                
                //previous meme image section
                ZStack {
                    
                    Button(action: {
                        
                        if model.localMemeFile.previousMeme != "" {
                            self.isMemeShowing = true
                        }
                        
                    }, label: {
                        
                        if model.localMemeFile.previousMeme != "" {
                            URLImage(url: model.localMemeFile.previousMeme, allowZoom: false)
                                .scaledToFit()
                                .frame(width: 350, height: 250, alignment: .center)
                                .shadow(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5), radius: 5, x: 5, y: 5)
                                .onAppear {
                                    buttonText = model.memeAlreadyFavourited(favouritedMeme: model.localMemeFile.previousMeme)
                                }
                        }
                        else {
                            URLImage(url: "loading", allowZoom: false)
                                .scaledToFit()
                                .frame(width: 350, height: 250, alignment: .center)
                                .shadow(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5), radius: 5, x: 5, y: 5)
                        }
                        
                        
                        
                    })
                    .sheet(isPresented: $isMemeShowing){
                        MemeFullScreen(memeImage:  model.localMemeFile.previousMeme, memeIndexSelected: 0)
                    }
                    .contextMenu{
                        //buttonText = model.memeAlreadyFavourited(favouritedMeme: model.localMemeFile.previousMeme)
                        
                        Button("\(buttonText)") {
                            let addWork = model.addFavouriteMeme(favouritedMeme: model.localMemeFile.previousMeme)
                            if addWork == false {
                                //meme already exists and was not added, show message alert
                                alreadyAddedToFavourites = true
                            }
                            //update button text
                            buttonText = model.memeAlreadyFavourited(favouritedMeme: model.localMemeFile.previousMeme)
                        }
                        .alert(isPresented: $alreadyAddedToFavourites) {
                            Alert(title: Text("Meme has already been favourited"))
                        }
                        
                        Button("Save to Photos") {
                            model.saveImage(saveImageName: model.localMemeFile.previousMeme)
                        }
                        
                    }
                    .padding(.bottom, 20)
                    
                }
                
            }
        }
        
        
    }
}

struct NewAlarm_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AlarmModel())
    }
}
