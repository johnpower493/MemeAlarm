//
//  ContentView.swift
//  MemeAlarm
//
//  Created by Gabriel Davila on 22/8/21.
//

import SwiftUI

struct MainTabView: View {
    
    @EnvironmentObject var model: AlarmModel
    let iconColor:Color = .red
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.systemGray5
        UITabBar.appearance().unselectedItemTintColor = UIColor.systemGray
    }
    
    var body: some View {
        
        TabView {
            
            HomeView()
                .tabItem {
                    VStack {
                        Image(systemName: "house.fill")
                            .foregroundColor(iconColor)
                        Text("Home")
                        
                    }
                }
                .onAppear {
                    model.whatIsNextAlarm()
                    model.randMeme()
                }
            
            ListAlarms()
                .tabItem {
                    VStack {
                        Image(systemName: "alarm.fill")
                            .foregroundColor(iconColor)
                        Text("Alarm")
                        
                    }
                }
                .onAppear {
                    model.whatIsNextAlarm()
                    model.randMeme()
                }
            
            ListFavourites()
                .tabItem {
                    VStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(iconColor)
                        Text("Favourites")
                        
                    }
                }
                .onAppear {
                    model.whatIsNextAlarm()
                    model.randMeme()
                }
            
            Settings()
                .tabItem {
                    VStack {
                        Image(systemName: "questionmark")
                            .foregroundColor(iconColor)
                        Text("Help")
                        
                    }
                }
                .onAppear {
                    model.whatIsNextAlarm()
                    model.randMeme()
                }
            
            
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    @EnvironmentObject var model: AlarmModel
    static var previews: some View {
        MainTabView()
            .environmentObject(AlarmModel())
        
    }
}
