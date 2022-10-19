//
//  Settings.swift
//  MemeAlarm
//
//  Created by Gabriel Davila on 22/8/21.
//

import SwiftUI

struct Settings: View {
    
    //variables set up here
    
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
                    
                    ScrollView {
                        VStack {
                            NavigationLink (
                                destination:
                                    SettingsDetailView(textToDisplay: "HowTo")
                                , label: {
                                    WhiteBoxList(textToShow: "How to use MemeAlarm")
                                })
                            .padding(.bottom, 10)
                            
                            
                            NavigationLink (
                                destination:
                                    SettingsDetailView(textToDisplay: "About")
                                , label: {
                                    WhiteBoxList(textToShow: "About")
                                })
                            
                            
                        }
                    }
                    
                }
                .navigationBarTitle("Back")
                .navigationBarHidden(true)
            }
            
        }
        
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
