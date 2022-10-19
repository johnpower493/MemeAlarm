//
//  WhiteBoxList.swift
//  MemeAlarm
//
//  Created by Gabriel Davila on 14/4/2022.
//

import SwiftUI

struct WhiteBoxList: View {
    
    @State var textToShow:String
    
    var body: some View {
        
        ZStack (alignment: .leading) {
            
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal, 20.0)
                .frame(height: 50)
                .shadow(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5), radius: 5, x: 5, y: 5)
            
            //let displayTime:String = model.localMemeFile.allAlarms[index].alarmTime
            HStack {
                Text(textToShow)
                    .foregroundColor(.black)
                    
            }
            .padding(.leading, 30)
            
        }
    }
}

struct WhiteBoxList_Previews: PreviewProvider {
    static var previews: some View {
        WhiteBoxList(textToShow: "Hey")
    }
}
