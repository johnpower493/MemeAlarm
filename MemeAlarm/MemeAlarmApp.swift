//
//  MemeAlarmApp.swift
//  MemeAlarm
//
//  Created by Gabriel Davila on 22/8/21.
//

import SwiftUI
import Firebase

@main
struct MemeAlarmApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        //initialise Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(AlarmModel())
                .environmentObject(SoundControls())
        }
    }
}


