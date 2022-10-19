//
//  EditAlarm.swift
//  MemeAlarm
//
//  Created by Gabriel Davila on 1/9/21.
//

import SwiftUI

struct EditAlarm: View {
    
    @EnvironmentObject var model: AlarmModel
    @EnvironmentObject var sounds: SoundControls
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var updateVal:daysOfWeek = daysOfWeek()
    
    @Binding var updateView:Bool
    
    //actual alarm detail that we're editing
    @State var editMemeAlarm:MemeAlarm
    
    //view variables
    @State var logoLocation:CGFloat
    @State var editOrNewText:String = "Edit"
    
    //local binding variables not set until saved, so that when you hit cancel it doesn't save
    @State var localToggle:Bool
    @State var localMemeCategory:String
    @State var localAlarmDays:String
    @State var localTime:String = ""
    @State var localTimeDate:Date = Date()
    @State var localLabel:String = ""
    @State var localSound:String = ""
    
    //sheet binding variables
    @State var selectCategoryShowing = false
    @State var selectAlarmDaysShowing = false
    @State var filledAlarmDetailsIncorrectly = false
    @State var selectSoundShowing = false
    
    //notifications variable
    let center = UNUserNotificationCenter.current()
    
    //padding universal values
    var listPaddingLeading:CGFloat = 10
    var listPaddingBottom:CGFloat = 10
    
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
                        .padding(.top, logoLocation)
                    
                    ScrollView {
                        ZStack {
                        //card rectangle
                        Rectangle()
                            .foregroundColor(.white)
                            .cornerRadius(40)
                            .padding(.horizontal, 20.0)
                            .padding(.bottom, 20)
                            .shadow(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.5), radius: 5, x: 5, y: 5)
                        
                        VStack {
                            
                            HStack{
                                Text("\(editOrNewText) Alarm")
                                    .font(.title3)
                                    .bold()
                                    .padding(.leading, 40)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                //set up enabled alarm toggle
                                Toggle("", isOn: $localToggle)
                                    .padding(.trailing, 40)
                                
                            }
                            .padding(.top, 15)
                            
                            //Set time
                            //Text("Time: ")
                            //    .bold()
                            //    .padding(.bottom, listPaddingBottom)
                            DatePicker("Please selct time", selection: $localTimeDate, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(WheelDatePickerStyle())
                                .frame(width: 120)
                                .accentColor(.black)
                                .colorInvert().colorMultiply(.black)
                            
                            LazyVGrid (columns: [GridItem(.fixed(120)), GridItem(.fixed(135))], alignment: .leading) {
                                
                                //set label with text input
                                Text("Label: ")
                                    .bold()
                                    .padding(.bottom, listPaddingBottom)
                                    .foregroundColor(.black)
                                TextField("\(editMemeAlarm.label)", text: $localLabel)
                                    .padding(.bottom, listPaddingBottom)
                                    .colorInvert().colorMultiply(.black)
                                
                                //set days with text input
                                Text("Days: ")
                                    .bold()
                                    .padding(.bottom, listPaddingBottom)
                                    .foregroundColor(.black)
                                Button {
                                    selectAlarmDaysShowing = true
                                    //update model.AlarmDays here
                                    model.alarmDays = model.setDaysofWeek(selectedDays: localAlarmDays)
                                    self.updateVal.name = localAlarmDays
                                } label: {
                                    //Text("\(localAlarmDays)")
                                    DayCircles(selectedDays: $localAlarmDays, fontSize: 8, circleBorder: 1)
                                }
                                .sheet(isPresented: $selectAlarmDaysShowing) {
                                    SelectDays(selectedDayBinding: $localAlarmDays, previouslySelectedDays: localAlarmDays)
                                }
                                
                                //set memeCategory with New View Input
                                Text("Category: ")
                                    .bold()
                                    .padding(.bottom, listPaddingBottom)
                                    .foregroundColor(.black)
                                //button to select category
                                Button {
                                    //code here
                                    selectCategoryShowing = true
                                } label: {
                                    Text("\(localMemeCategory)")
                                        .bold()
                                        .padding(.bottom, listPaddingBottom)
                                        .foregroundColor(.blue)
                                }
                                .sheet(isPresented: $selectCategoryShowing) {
                                    SelectCategory(memeSelection: $localMemeCategory)
                                }
                                
                                //set sound with text input
                                Text("Sound: ")
                                    .bold()
                                    .padding(.bottom, listPaddingBottom)
                                    .foregroundColor(.black)
                                Button {
                                    selectSoundShowing = true
                                    
                                } label: {
                                    Text("\(localSound)")
                                        .bold()
                                        .padding(.bottom, listPaddingBottom)
                                        .foregroundColor(.blue)
                                }
                                .sheet(isPresented: $selectSoundShowing, content: {
                                    ListSounds(localSounds: $localSound)
                                })
                                
                                
                            }
                            .ignoresSafeArea()
                            .padding(.horizontal, 40)
                            .padding(.bottom, 25)
                            
                            //buttons
                            HStack {
                                Spacer()
                                
                                //save button
                                Button {
                                    // full code for save button in function below
                                    saveButtonCode()
                                    updateView = true
                                    
                                } label: {
                                    
                                    Text("Save")
                                        .foregroundColor(.blue)
                                        .bold()
                                }
                                .padding(.trailing, 25)
                                .alert(isPresented: $filledAlarmDetailsIncorrectly) {
                                    Alert(title: Text("Please fill in required fields"))
                                }
                                
                                //cancel button
                                Button {
                                    //cancel code here
                                    self.presentationMode.wrappedValue.dismiss()
                                    
                                } label: {
                                    Text("Cancel")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.bottom, 50)
                            .padding(.trailing, 40)
                            
                            Spacer()
                            
                        }
                        
                    }
                    
                    }
                }
                
                Spacer ()
                
            }
            .navigationBarTitle(Text("Back"), displayMode: .inline)
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.top)
            
            Spacer()
            
        }
        
    }
    
    func findSaveMemeIndex(idToLookfor: String) -> Int {
        
        //write
        let loopCount = model.localMemeFile.allAlarms.count
        
        for index in 0..<loopCount {
            
            if model.localMemeFile.allAlarms[index].id == idToLookfor {
                return index
            }
            
        }
        
        return 0
    }
    
    func saveButtonCode() {
        
        // check if at least label is filled out correctly
        if localLabel != "" || editMemeAlarm.label != "" {
            
            //no alert becuase label is available
            filledAlarmDetailsIncorrectly = false
            
            //update editMemeAlarm model with updated data or if not available then with it's same data as it was not changed
            if editMemeAlarm.id == "" {
                editMemeAlarm.id = UUID().uuidString
            }
            //if local time is not empty, means it was updated by user, so we want to use it
            //temporarliy always write value
            if localTime == "" {
                //convert date picker value to string to save to local time
                var date = DateComponents()
                let calendar = Calendar.current
                
                date.hour = calendar.component(.hour, from: localTimeDate)
                var dateHourString:String = String(date.hour!)
                if dateHourString.count == 1{
                    //add leading 0 to hour string
                    dateHourString = "0" + dateHourString
                }
                
                date.minute = calendar.component(.minute, from: localTimeDate)
                var dateMinuteString:String = String(date.minute!)
                if dateMinuteString.count == 1 {
                    //add leading 0 to minute string
                    dateMinuteString = "0" + dateMinuteString
                }
                
                let timeString:String = String("\(dateHourString):\(dateMinuteString)")
                
                //save to editMemeAlarm
                editMemeAlarm.alarmTime = timeString
            }
            if localAlarmDays != "" {
                editMemeAlarm.alarmDays = localAlarmDays
            }
            if localLabel != "" {
                editMemeAlarm.label = localLabel
            }
            if localSound != "" {
                editMemeAlarm.sound = localSound
            }
            if localMemeCategory != "" {
                editMemeAlarm.memeCategory = localMemeCategory
            }
            
            editMemeAlarm.enabledAlarm = localToggle
            
            
            //test if creating new alarm or editing alarm
            if editOrNewText == "New" {
                //do new alarm code
                
                model.localMemeFile.allAlarms.append(editMemeAlarm)
                
                if model.localMemeFile.allAlarms.count == 1 {
                    //new and first alarm create, so update next alarmID to selection to 0
                    model.nextAlarmID = 0
                }
                
            }
            else {
                
                //update model.localmemefile with the textfield data
                let idToLookFor = editMemeAlarm.id
                
                //run a fucntion that loops through model.localmemefile.allarms.count to find the id when need to write these lcoal data files to
                let foundIndex = findSaveMemeIndex(idToLookfor: idToLookFor)
                
                //replace contents of model alarm array with currently edited meme
                model.localMemeFile.allAlarms[foundIndex] = editMemeAlarm
                
            }
            
            //clear all existing notifications
            center.removeAllDeliveredNotifications()
            center.removeAllPendingNotificationRequests()
            
            //create new notifications
            for item in model.localMemeFile.allAlarms {
                
                if item.enabledAlarm == true {
                    let content = UNMutableNotificationContent()
                    content.title = item.label
                    content.body = "Click here to check out your new Meme!"
                    let soundName = UNNotificationSoundName(rawValue: "\(editMemeAlarm.sound).mp3")
                    content.sound = UNNotificationSound(named: soundName)
                    let imageName = "logo"
                    let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png")
                    let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL!, options: .none)
                    content.attachments = [attachment]
                    
                    //custom buttom code
                    content.categoryIdentifier = "alarm" //"\(item.label)"
                    content.userInfo = ["customData" : "\(item.memeCategory)"]
                    
                    let now = Date()
                    var date = DateComponents()
                    let calendar = Calendar.current
                    let currAlarmTime = model.convertStringToDate(time: item.alarmTime)
                    
                    //create a loop to add up to 7 notifications per alarm for each day user selected
                    let selectedDays = model.convertStringToCharArray(alarmDays: item.alarmDays)
                    for alarmDay in 0..<selectedDays.count {
                        
                        //date.day = calendar.component(.day, from: now)
                        //date.month = calendar.component(.month, from: now)
                        date.year = calendar.component(.year, from: now)
                        date.hour = calendar.component(.hour, from: currAlarmTime)
                        date.minute = calendar.component(.minute, from: currAlarmTime)
                        //date.second = calendar.component(.second, from: currAlarmTime)
                        
                        let selectDayIndex = selectedDays[alarmDay]
                        
                        if alarmDay == 0 { //0 for alarm day is Monday alarm
                            if selectDayIndex != " " {
                                date.weekday = 2 //ios uses 2 for Monday
                                //print(date)
                            }
                        }
                        if alarmDay == 1 { //1 for alarm day is Tuesday alarm
                            if selectDayIndex != " " {
                                date.weekday = 3 //ios uses 3 for Tuesday
                                //print(date)
                            }
                            
                        }
                        if alarmDay == 2 { //2 for alarm day is Wednesday alarm
                            if selectDayIndex != " " {
                                date.weekday = 4 //ios uses 4 for Wednesday
                                //print(date)
                            }
                            
                        }
                        if alarmDay == 3 { //3 for alarm day is Thursday alarm
                            if selectDayIndex != " " {
                                date.weekday = 5 //ios uses 5 for Thursday
                                //print(date)
                            }
                            
                        }
                        if alarmDay == 4 { //4 for alarm day is Friday alarm
                            if selectDayIndex != " " {
                                date.weekday = 6 //ios uses 6 for Friday
                                //print(date)
                            }
                            
                        }
                        if alarmDay == 5 { //5 for alarm day is Saturday alarm
                            if selectDayIndex != " " {
                                date.weekday = 7 //ios uses 7 for Saturday
                                //print(date)
                            }
                            
                        }
                        if alarmDay == 6 { //6 for alarm day is Sunday alarm
                            if selectDayIndex != " " {
                                date.weekday = 1 //ios uses 1 for Sunday
                                //print(date)
                            }
                            
                        }
                        
                        if selectDayIndex != " " {
                            let idRequest = "\(item.id)\(alarmDay)"
                            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
                            let request = UNNotificationRequest(identifier: idRequest, content: content, trigger: trigger)
                            
                            //custom button code
                            //center.delegate = self
                            let show = UNNotificationAction(identifier: "show", title: "Show me the meme", options: .foreground)
                            let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])
                            center.setNotificationCategories([category])
                            
                            center.add(request) { (error : Error?) in
                                if let theError = error {
                                    //there were errors
                                    
                                    print(theError)
                                    
                                }
                            }
                            
                            //print notifications for debugging if required
                            /*center.getPendingNotificationRequests(completionHandler: {requests in
                                for requests1 in requests {
                                    print(requests1)
                                }
                            })*/
                            
                        }
                    }
                }
                
            }
            
            //calculate what the next alarm is
            model.whatIsNextAlarm()
            
            //write to localMemeFile json file
            model.addMemeAlarm(writeDataFile: model.localMemeFile)
            
            //close screen now
            self.presentationMode.wrappedValue.dismiss()
        }
        else {
            filledAlarmDetailsIncorrectly = true
        }
        
    }
    
}

struct SelectCategory: View {
    
    @EnvironmentObject var model: AlarmModel
    @Environment(\.presentationMode) var presentationMode0
    @Binding var memeSelection:String
    
    var body: some View {
        VStack {
            Text("Categories")
                .font(.title)
                .bold()
            
            List {
                
                ForEach (0..<model.memeCategories.count) { categ in
                    
                    Button("\(model.memeCategories[categ])") {
                        
                        memeSelection = model.memeCategories[categ]
                        self.presentationMode0.wrappedValue.dismiss()
                        
                    }
                    
                    
                }
            }
        }
        
    }
}

struct SelectDays: View {
    
    @EnvironmentObject var model: AlarmModel
    @Environment(\.presentationMode) var presentationMode1
    @Binding var selectedDayBinding:String
    @State var previouslySelectedDays:String
    @State var newDays = 0
    
    @State var selectionImage:String = "checkmark"
    @ObservedObject var updateVal:daysOfWeek = daysOfWeek()
    @State var daysAreNotSelected = false
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            Text("Alarm on selected Days")
                .font(.title)
                .bold()
                .padding(.top, 10)
            
            let daysInArray = model.convertStringToCharArray(alarmDays: selectedDayBinding)
            VStack {
                List {
                    
                    ForEach (0..<daysInArray.count) {index in
                        
                        HStack {
                            
                            Button(action: {
                                if model.alarmDays[index].isSelected == true {
                                    model.alarmDays[index].isSelected = false
                                    updateVal.name = String(index)
                                    
                                } else {
                                    model.alarmDays[index].isSelected = true
                                    updateVal.name = String(index)
                                }
                                
                            }) {
                                
                                HStack {
                                    Text(model.alarmDays[index].name)
                                    
                                    Spacer()
                                    
                                    if model.alarmDays[index].isSelected {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                            .animation(.easeIn)
                                    } else if model.alarmDays[index].isSelected == false {
                                        Image(systemName: "circle")
                                            .foregroundColor(.blue)
                                            .animation(.easeOut)
                                    }
                                }
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                
                HStack {
                    
                    Spacer()
                    
                    Button {
                        //Do OK code here
                        //check if any day is selected if none, show alert
                        let testSelectDays = model.selectedDaysWeekToString(selectedDays: model.alarmDays)
                        if testSelectDays == "_______" {
                            daysAreNotSelected = true
                        }
                        
                        //if days are selected then run ok code
                        if daysAreNotSelected == false {
                            selectedDayBinding = model.selectedDaysWeekToString(selectedDays: model.alarmDays)
                            updateVal.name = selectedDayBinding
                            self.presentationMode1.wrappedValue.dismiss()
                        }
                    } label: {
                        Text("OK")
                    }
                    .alert(isPresented: $daysAreNotSelected) {
                        Alert(title: Text("Please select at least 1 day"))
                    }
                    
                    
                    Spacer()
                    
                    Button("Cancel") {
                        //undo changed code to previously selected
                        selectedDayBinding = previouslySelectedDays
                        updateVal.name = selectedDayBinding
                        self.presentationMode1.wrappedValue.dismiss()
                    }
                    
                    Spacer()
                    
                }
                .padding(.bottom, 200)
                Spacer()
            }
            
            Spacer()
        }
        
    }
}

