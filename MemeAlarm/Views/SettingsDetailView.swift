//
//  SettingsDetailView.swift
//  MemeAlarm
//
//  Created by Gabriel Davila on 14/4/2022.
//

import SwiftUI

struct SettingsDetailView: View {
    
    @State var textToDisplay:String
    
    var body: some View {
        NavigationView {
            ZStack {
                
                LinearGradient(gradient: Gradient(colors: [Color(red: 250/255, green: 229/255, blue: 149/255), Color.white]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                GeometryReader { geo1 in
                    
                    VStack {
                        
                        Image("logo-inline")
                            .resizable()
                            .frame(width: 350, height: 125)
                            .aspectRatio(contentMode: .fill)
                        //.padding(.leading, 10)
                            .padding(.top, 75)
                        
                        if textToDisplay == "About" {
                            VStack{
                                
                                Text("About MemeAlarm")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.black)
                                    .padding(.leading, 0)
                                
                                ZStack {
                                    
                                    HStack {
                                        Spacer()
                                        Rectangle()
                                            .foregroundColor(.white)
                                            .cornerRadius(40)
                                            .padding(.horizontal, 20.0)
                                            .shadow(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5), radius: 5, x: 5, y: 5)
                                        Spacer()
                                    }
                                    
                                    ScrollView {
                                        
                                        VStack (alignment: .leading) {
                                            Text("This app was created by \n\rGabriel Davila & John Power\nPISQUAD314\n")
                                            
                                            Label("Copyright 2022", systemImage:"c.circle")
                                        }
                                        //.padding(.leading, 0)
                                    }
                                    .padding(.top, 10)
                                    .foregroundColor(.black)
                                    
                                }
                                
                                Spacer()
                            }
                            
                        }
                        else { //it's probably "HowTo" page not about
                            
                            VStack {
                                
                                Text("How to use MemeAlarm")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.black)
                                //.frame(width: geo1.size.width, alignment: .leading)
                                    .padding(.horizontal, 40)
                                
                                ZStack {
                                    
                                    HStack {
                                        Spacer()
                                        Rectangle()
                                            .foregroundColor(.white)
                                            .cornerRadius(40)
                                            .padding(.horizontal, 20.0)
                                            .shadow(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5), radius: 5, x: 5, y: 5)
                                        Spacer()
                                    }
                                    
                                    ScrollView {
                                        VStack (alignment: .leading) {
                                            VStack{
                                                Text("1. Home Tab")
                                                    .bold()
                                                Image("Home")
                                                    .resizable()
                                                    .frame(width: geo1.size.width/2, height: geo1.size.height/2)
                                                
                                                Text("The Home tab allows you to view the next scheduled alarm\n- You can tap on the pencil icon to edit the alarm\n- You'll be able to see the days next alarm is set to go off")
                                                Text("- Most importantly, this is where you can see your latest meme \n- You can tap on the meme to view it in full screen \n- You can tap and hold to save the image to your favourites, or save it to your camera roll\n")
                                            }
                                            VStack {
                                                Text("2. Alarm Tab")
                                                    .bold()
                                                Image("Alarm")
                                                    .resizable()
                                                    .frame(width: geo1.size.width/2, height: geo1.size.height/2)
                                                
                                                Text("The Alarm tab shows you a list of all of your Alarms \n- You can add new alarms by tapping the blue + button \n- You can edit an alarm  by tapping on it \n- You can delete on an Alarm by tapping and holding and selecting Delete Alarm, or you can swipe right to left to delete the alarm\n")
                                                
                                                Text("Edit Alarm")
                                                    .bold()
                                                Image("EditAlarm")
                                                    .resizable()
                                                    .frame(width: geo1.size.width/2, height: geo1.size.height/2)
                                                Text("When you tap on an Alarm, you will go to it's edit page. From here you can; \n- enable/disable the alarm with the toggle button \n- You can select the time \n- You can rename your alarm \n- You can select the days you want the alarm \n- You can select the type of meme category you will recieve when the alarm goes off \n- You can select the sound you will hear when the alarm goes off\n")
                                                Text("IMPORTANT - Apple iOS does not allow apps to generate real Alarms, so you will have to make sure your silent switch is not on and your volume is on full volume to hear the alarm. \nAn extra tip is to allow MemeAlarm in allowed Apps if you use Focus Mode and you want to hear and see the notifications \n")
                                            }
                                            VStack{
                                                Text("3. Favourites Tab")
                                                    .bold()
                                                Image("Favourites")
                                                    .resizable()
                                                    .frame(width: geo1.size.width/2, height: geo1.size.height/2)
                                                
                                                Text("The Favourites tab shows you a list of all of your favourited memes")
                                                Text("- You can add memes from the Home Tab, but tapping and holding on the Latest Meme and select Add to Favourites \n- You can tap on a meme to open it in full screen \n- You can save to camera roll by tapping and holding on the preview image \n- You can also remove memes from your Favourites list by tapping and holding on the preview image\n\n")
                                            }
                                            
                                        }
                                        .padding(.horizontal, 40)
                                        
                                    }
                                    .padding(.vertical, 10)
                                    .foregroundColor(.black)
                                    
                                }
                                
                                Spacer()
                                
                            }
                        }
                        
                    }
                    //.navigationBarTitle(Text("Back"))
                    .navigationBarHidden(false)
                    
                }
                
            }
            .navigationBarTitle(Text("Back"), displayMode: .inline)
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.top)
        }
        
    }
}

struct SettingsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsDetailView(textToDisplay: "About")
    }
}
