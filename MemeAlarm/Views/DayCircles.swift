//
//  DayCircles.swift
//  MemeAlarm
//
//  Created by Gabriel Davila on 9/9/21.
//

import SwiftUI

struct DayCircles: View {
    
    @EnvironmentObject var model:AlarmModel
    
    @Binding var selectedDays:String
    @State var fontSize:CGFloat = 20
    @State var circleBorder:CGFloat = 3
    
    
    var body: some View {
            
        let arrayDays = model.convertStringToCharArray(alarmDays: selectedDays)
        
        HStack {
            
            ForEach (0..<arrayDays.count, id:\.self) {index in
                
                ZStack {
                    
                    if arrayDays[index] != " " {
                        Circle()
                            .stroke(lineWidth: circleBorder)
                            .foregroundColor(.black)
                        
                        Circle()
                            .foregroundColor(Color(red: 250/255, green: 229/255, blue: 149/255))
                        
                    } else {
                        
                        Circle()
                            .stroke(lineWidth: 1)
                            .foregroundColor(.black)
                        
                    }
                    
                    Text("\(arrayDays[index])")
                        .foregroundColor(.blue)
                        .bold()
                        .font(.system(size: fontSize))
                    
                }
            }

        }
    }
       
}
