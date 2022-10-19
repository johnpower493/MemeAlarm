//
//  ListAlarms.swift
//  MemeAlarm
//
//  Created by Gabriel Davila on 22/8/21.
//

import SwiftUI

struct ListAlarms: View {
    
    @EnvironmentObject var model: AlarmModel
    @EnvironmentObject var sounds: SoundControls
    
    @State var navigationButtonText: String = "Back"
    @State var isDragging = false
    @State var updateView = false
    
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
                    
                    HStack {
                        
                        Text("Alarm")
                            .font(.title)
                            .bold()
                            .padding(.leading, 20)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        NavigationLink (
                            destination:
                                //need to pass alarm details to go into New alarm
                                EditAlarm(updateView: $updateView, editMemeAlarm: MemeAlarm(), logoLocation: 75, editOrNewText: "New", localToggle: true, localMemeCategory: "Funny", localAlarmDays: "MTWTFSS", localTime: "", localTimeDate: model.convertStringToDate(time: "00:00"), localLabel: "New Alarm", localSound: "Siren")
                            
                            ,label: {
                                
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 25))
                                    .padding(.trailing, 25)
                                    .padding(.bottom, 10)
                                
                            })
                            .accentColor(.black)
                    }
                    
                    VStack {
                        ScrollView {
                            ForEach (0..<model.localMemeFile.allAlarms.count, id: \.self) { index in
                                
                                NavigationLink (
                                    destination:
                                        //need to pass alarm details to go into edit alarm
                                        EditAlarm(updateView: $updateView, editMemeAlarm: model.localMemeFile.allAlarms[index], logoLocation: 75, localToggle:  model.localMemeFile.allAlarms[index].enabledAlarm, localMemeCategory: model.localMemeFile.allAlarms[index].memeCategory, localAlarmDays: model.localMemeFile.allAlarms[index].alarmDays, localTimeDate: model.convertStringToDate(time: model.localMemeFile.allAlarms[index].alarmTime), localSound: model.localMemeFile.allAlarms[index].sound)
                                    
                                    
                                    ,label: {
                                        ZStack (alignment: .leading) {
                                            
                                            Rectangle()
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                                .padding(.horizontal, 20.0)
                                                .frame(height: 50)
                                                .shadow(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5), radius: 5, x: 5, y: 5)
                                            
                                            //let displayTime:String = model.localMemeFile.allAlarms[index].alarmTime
                                            HStack {
                                                Text("\(model.localMemeFile.allAlarms[index].label)  -")
                                                    .foregroundColor(model.localMemeFile.allAlarms[index].enabledAlarm == true ? .black: Color(red: 180/255, green: 180/255, blue: 180/255))
                                                    
                                                Text(model.convertStringToDate(time: model.localMemeFile.allAlarms[index].alarmTime), style: .time)
                                                    .foregroundColor(model.localMemeFile.allAlarms[index].enabledAlarm == true ? .black: Color(red: 180/255, green: 180/255, blue: 180/255))
                                                    
                                            }
                                            .padding(.leading, 30)
                                        }
                                        .padding(.bottom, 10)
                                        
                                    })
                                    .accentColor(.black)
                                    .contextMenu{
                                        Button{
                                            deleteAlarm(index: index)
                                            
                                        } label: {
                                            Text("Delete Alarm")
                                        }
                                    }
                                    .highPriorityGesture(
                                        DragGesture(minimumDistance: 125)
                                            .onChanged({ value in
                                                if value.startLocation.x > value.location.x {
                                                    //swipe left
                                                    self.isDragging = true
                                                    //print("swiping left")
                                                } else if (value.startLocation.x == value.location.x) {
                                                    //swipe right code, not required right now
                                                    self.isDragging = false
                                                }
                                                
                                            })
                                            .onEnded({ value in
                                                //print("finished swiping left")
                                                if self.isDragging == true {
                                                    self.isDragging = false
                                                    deleteAlarm(index: index)
                                                }
                                            })
                                    )
                                    .contentShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                        }
                        Spacer()
                    }
                }
                .navigationBarTitle(Text(navigationButtonText))
                .navigationBarHidden(true)
                
            }
            
            
            
        }
        
    }
    
    func deleteAlarm (index: Int) {
        
        if index >= 0 && index <= model.localMemeFile.allAlarms.count {
            model.localMemeFile.allAlarms.remove(at: index)
            
            if model.localMemeFile.allAlarms.count == 0 {
                //no more alarms, set next alarm ID to -1
                model.nextAlarmID = -1
            }
            
            model.addMemeAlarm(writeDataFile: model.localMemeFile)
            
        }
        
        model.whatIsNextAlarm()
        
    }
    
}


struct ListAlarms_Previews: PreviewProvider {
    static var previews: some View {
        ListAlarms().environmentObject(AlarmModel())
    }
}
