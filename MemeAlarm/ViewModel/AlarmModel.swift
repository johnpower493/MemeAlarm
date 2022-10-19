//
//  AlarmModel.swift
//  MemeAlarm
//
//  Created by Gabriel Davila on 23/8/21.
//

import Foundation
import Firebase

class AlarmModel: ObservableObject {
    
    //set up database connection
    let db = Firestore.firestore()
    
    @Published var memeAlarmList = [MemeAlarm]()
    
    @Published var memeCategories = [String]()
    
    //set up an empty memeObject object
    @Published var memeObjects = [memeObject]()
    
    //set up an empty localMemeData
    @Published var localMemeFile = localMemeData()
    
    //set up nextAlarm object
    @Published var nextAlarmID = -1
    
    @Published var refreshVariable = 0
    
    @Published var alarmDays:[daysOfWeek] = [daysOfWeek]()
    
    @Published var notificationsAllowed:Bool = true
    
    @Published var timer: Timer?
    
    init() {
        
        //get list of categories from online database
        getOnlineCategories()
        
        //local setup method
        localSetup()
        
        //select next alarm to display in home screen
        whatIsNextAlarm()
        
        //ask for alert permissions and provide error to say you need allow for notifications
        requestPermission()
        
        //get online memes DB on set up - so we can call next meme from memeObjects
        getOnlineMemesDB()
        
        //let testVal == UserDefaults
        
        let now = Date.timeIntervalSinceReferenceDate
        let delayFraction = trunc(now) - now

        //Calculate a delay until the next even minute
        let delay = 60.0 - Double(Int(now) % 60) + delayFraction
        
        self.runNewPreviousMeme()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.runNewPreviousMeme()
            self.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
                self.runNewPreviousMeme()
            }
            
        }
        
    }
    
// MARK: Setup Functions
    func runNewPreviousMeme() {

        //let userInfo = response.notification.request.content.userInfo
        //if let customData = userInfo["customData"] as? String {
        //    print("test info")
        //}
        
        //set new previious meme if alarm has passed
        self.localMemeFile.previousMeme = localMemeFile.tomorrowMeme
        
        //run these update codes also
        whatIsNextAlarm()
        randMeme()
        
    }
    
    func requestPermission() {
        
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            if granted == false {
                //there was an error
                print("Please allow permission to show notifications to show you alarm")
                self.notificationsAllowed = false
                
            }
        }
        
    }
    
    func getOnlineCategories() {
        
        //specify collection
        let memes = db.collection("memeCategories")
        
        memes.getDocuments { (docSnapshot, error) in
            
            if error == nil && docSnapshot != nil {
                
                var memeCat = [String]()
                var localIndex = 0
                
                for doc in docSnapshot!.documents {
                    
                    var m = ""
                    
                    m = doc["name"] as? String ?? ""
                    
                    //print(m)
                    
                    memeCat.append(m)
                    
                    localIndex += 1
                }
                
                DispatchQueue.main.async {
                    self.memeCategories = memeCat
                    self.memeCategories.sort() //sort by alphabetical order
                    
                }
            }
        }
        
    }
    
    func getOnlineMemesDB() {
        
        //specify collection
        let memes = db.collection("Memes")
        
        memes.getDocuments { (docSnapshot, error) in
            
            if error == nil && docSnapshot != nil {
                
                var memeObjectsDB = [memeObject]()
                
                for doc in docSnapshot!.documents {
                    
                    var m = memeObject()
                    
                    m.id = doc["itemID"] as? String ?? ""
                    m.imageURL = doc["imageURL"] as? String ?? ""
                    m.memeCategory = doc["memeCategory"] as? String ?? ""
                    
                    //print(m.imageURL)
                    
                    memeObjectsDB.append(m)
                }
                
                DispatchQueue.main.async {
                    self.memeObjects = memeObjectsDB
                    
                }
            }
        }
        
    }
    
    func localSetup() {
        
        localMemeFile = StorageFunctions.retrieveSettings()
        
    }
    
    func randMeme() {
        
        if localMemeFile.allAlarms.count > 0 && memeObjects.count > 0 {
            //find category of nextAlarm
            let nextCat = localMemeFile.allAlarms[nextAlarmID].memeCategory
            
            //go through all memeCat to find which meme is of the same category as alarm selected and append to tempArray
            var tempArray = [String]()
            
            for i in 0..<memeObjects.count {
                if memeObjects[i].memeCategory == nextCat {
                    tempArray.append(memeObjects[i].imageURL)
                }
            }
            
            if tempArray.count > 0 {
                //select a random integer from 0 to tempArray.count-1 to select next randomMeme
                let randMeme = Int.random(in: 0..<tempArray.count)
                
                localMemeFile.tomorrowMeme = tempArray[randMeme]
                
                //delete code
                //localMemeFile.previousMeme = memeObjects[randMeme].imageURL
                
                addMemeAlarm(writeDataFile: localMemeFile)
            }
        }
    }
    
// MARK: Data JSON Functions
    func addMemeAlarm(writeDataFile: localMemeData) {
        saveSettings(settings: writeDataFile)
        
    }
    
    func saveSettings(settings: localMemeData) {
        StorageFunctions.storeSettings(settings: settings)
    }
    
    func deleteSetting(at indexSet:IndexSet) {
        //localMemeFile.remove(atOffsets: indexSet)
        //saveSettings()
    }
    
    func memeAlreadyFavourited(favouritedMeme: String) -> String {
        //has meme already been added
        for i in 0..<localMemeFile.favouritedMemes.count {
            if localMemeFile.favouritedMemes[i] == favouritedMeme {
                return "Meme already added to Favourites!"
            }
        }
        
        return "Add to Favourites"
    }

    func addFavouriteMeme(favouritedMeme: String) -> Bool {
        
        if memeAlreadyFavourited(favouritedMeme: favouritedMeme) == "Add to Favourites" {
            //add meme to favourites
            localMemeFile.favouritedMemes.append(favouritedMeme)
            addMemeAlarm(writeDataFile: localMemeFile)
            return true
        }
        
        return false
    }
        
// MARK: Date Functions
    func whatIsNextAlarm() {
 
        //find out what right now is
        var firstAlarmIsLatestAlarm = true
        let now = Date()
        var date = DateComponents()
        let calendar = Calendar.current
        date.weekday = calendar.component(.weekday, from: now)
        date.hour = calendar.component(.hour, from: now)
        date.minute = calendar.component(.minute, from: now)
        
        if localMemeFile.allAlarms.count > 0 {
            //temp nextalarmid
            for alarms in 0..<localMemeFile.allAlarms.count {
                if localMemeFile.allAlarms[alarms].enabledAlarm == true {
                    
                    //potential next alarm to test
                    let date1Time = convertStringToDate(time: localMemeFile.allAlarms[alarms].alarmTime) //date for next alarm date
                    var date1 = DateComponents()
                    date1.hour = calendar.component(.hour, from: date1Time)
                    date1.minute = calendar.component(.minute, from: date1Time)
                    let date1Days = convertStringToCharArray(alarmDays: localMemeFile.allAlarms[alarms].alarmDays)
                    let date1Compared = nextAlarmDay(arrayDaysOfWeek: date1Days, currentDay: date.weekday!)
                    
                    if firstAlarmIsLatestAlarm {
                        //is alarm today?
                        //find out what is the next day for current next alarm and potential next alarm
                        let daysForNextAlarm1Init = singleNextAlarmDay(arrayDaysOfWeek: date1Days, currentDay: date.weekday!)
                        
                        if isAlarmStillToday(dateComp: date1) == true {
                            firstAlarmIsLatestAlarm = false
                            nextAlarmID = alarms
                        } else if daysForNextAlarm1Init != -1 && isAlarmStillToday(dateComp: date1) == false {
                            firstAlarmIsLatestAlarm = false
                            nextAlarmID = alarms
                        }
                        
                    } else {
                        
                        //current next alarm
                        let date2Time = convertStringToDate(time: localMemeFile.allAlarms[nextAlarmID].alarmTime) //date for next alarm date
                        var date2 = DateComponents()
                        date2.hour = calendar.component(.hour, from: date2Time)
                        date2.minute = calendar.component(.minute, from: date2Time)
                        let date2Days = convertStringToCharArray(alarmDays: localMemeFile.allAlarms[nextAlarmID].alarmDays)
                        let date2Compared = nextAlarmDay(arrayDaysOfWeek: date2Days, currentDay: date.weekday!)
                        
                        if date1Compared[date.weekday!] == date.weekday! && isAlarmStillToday(dateComp: date1) == true { //means new potential alarm is on current day & alarm hasn't already passed
                            
                            if date2Compared[date.weekday!] == date.weekday! && isAlarmStillToday(dateComp: date2) == true { //means current nextAlarmID is also today and alarm hasn't already passed
                                
                                if date1.hour! >= date.hour! && date1.hour! <= date2.hour! { //means date 1 (next potential alarm) should be nextalarm
                                
                                    nextAlarmID = alarms
                                    
                                } else {
                                    //
                                    
                                    if date1.hour! == date.hour! { //hours are same so compare minutes
                                        if date1.minute! > date.minute! { //minute is after current minute
                                            if date1.minute! < date2.minute! { //next test alarm is before current next alarm
                                                nextAlarmID = alarms
                                                
                                            }
                                            
                                        }
                                        
                                    } else if date1.hour! > date.hour! { //new alarm is after current hour
                                        if date1.hour! == date2.hour! { //hours same so compareminutes
                                            if date1.minute! < date2.minute! {
                                                nextAlarmID = alarms
                                            }
                                        } else if date1.hour! < date2.hour! {
                                            nextAlarmID = alarms
                                        }
                                    }
                                }
                            
                            } else {
                                nextAlarmID = alarms
                            }
                            
                        } else  { //not the same current today
                            
                            //find out what is the next day for current next alarm and potential next alarm
                            let daysForNextAlarm1 = singleNextAlarmDay(arrayDaysOfWeek: date1Days, currentDay: date.weekday!)
                            let daysForNextAlarm2 = singleNextAlarmDay(arrayDaysOfWeek: date2Days, currentDay: date.weekday!)
                            
                            if daysForNextAlarm1 != -1 { //alarm has day enabled in future and no alarm has been identified as next
                                if daysForNextAlarm1 < daysForNextAlarm2 && isAlarmStillToday(dateComp: date2) == false {
                                    //next potential alarm is next
                                    nextAlarmID = alarms
                                } else if daysForNextAlarm1 == daysForNextAlarm2 { //next alarm days is same for both alarms, find out which time is earlier
                                    if date1.hour! == date2.hour! { //hours are same so compare minutes
                                        if date1.minute! < date2.minute! { //next test alarm is before current next alarm
                                            nextAlarmID = alarms
                                        }
                                    } else if date1.hour! < date2.hour! { //new alarm is before current hour
                                        nextAlarmID = alarms
                                    }
                                }
                            } //if next1AlarmDay is -1 then it has no alarm day in future so do nothing, this should not happen
                        }
                        
                    }
                    
                    
                }
            }
            
            if nextAlarmID == -1 {  //code above didn't do anything so best to set nextAlarmID to something because there are alarms on and active
                nextAlarmID = 0
                print("error no alarm test early")
            }
            
        }
        else {
            nextAlarmID = -1
        }
        
    }
    
    func isAlarmStillToday(dateComp: DateComponents) -> Bool {
        
        let now = Date()
        var date = DateComponents()
        let calendar = Calendar.current
        date.hour = calendar.component(.hour, from: now)
        date.minute = calendar.component(.minute, from: now)
        
        if dateComp.hour! > date.hour! { //is dateComp hour greather than current hour?
            return true
        } else if dateComp.hour! == date.hour! { //dateComp hour is equal to current hour? check minutes
            if dateComp.minute! > date.minute! { //dateComp minute is after current hour so alarm has not passed yet
                return true
            }
        }
        
        //if it hasn't returned yet then alarm has probably already passed for today
        return false
    }
    
    func singleNextAlarmDay(arrayDaysOfWeek: [String], currentDay: Int) -> Int {
        
        var dates:[Int] = [0,0,0,0,0,0,0,0]
        var calcCurrentDay = currentDay
        
        //index for ios - monday = 1, tuesday = 2, wednesday = 3, thursday = 4, friday = 5, saturday = 6, sunday = 7
        
        //6 for alarm day is Sunday alarm
        if arrayDaysOfWeek[6] != " " {
            //ios uses 1 for Sunday
            dates[1] = 1
        }
        
        //0 for alarm day is Monday alarm
        if arrayDaysOfWeek[0] != " " {
            //ios uses 2 for Monday
            dates[2] = 2
        }
        
        //1 for alarm day is Tuesday alarm
        if arrayDaysOfWeek[1] != " " {
            //ios uses 3 for Tuesday
            dates[3] = 3
        }

        //2 for alarm day is Wednesday alarm
        if arrayDaysOfWeek[2] != " "  {
            //ios uses 4 for Wednesday
            dates[4] = 4
        }
        
        //3 for alarm day is Thursday alarm
        if arrayDaysOfWeek[3] != " " {
            //ios uses 5 for Thursday
            dates[5] = 5
        }
         
        //4 for alarm day is Friday alarm
        if arrayDaysOfWeek[4] != " "  {
            //ios uses 6 for Friday
            dates[6] = 6
        }
        
        //5 for alarm day is Saturday alarm
        if arrayDaysOfWeek[5] != " "  {
            //ios uses 7 for Saturday
            dates[7] = 7
        }
       
        for index in 1...7 {
            
            //alarm is not on today otherwise this func is not called
            if calcCurrentDay == 7 { //if current day is saturday so adding 1 day should make it Monday or 1
                calcCurrentDay = 1
            } else if calcCurrentDay < 7 {
                calcCurrentDay += 1 //increment day to see if alarm is on the next day
            }
            
            if dates[calcCurrentDay] == calcCurrentDay {
                return index
            }
            
        }
        
        return -1

    }
    
    func nextAlarmDay(arrayDaysOfWeek: [String], currentDay: Int) -> [Int] {
        
        var dates:[Int] = [0,0,0,0,0,0,0,0]
        
        //index for ios - monday = 1, tuesday = 2, wednesday = 3, thursday = 4, friday = 5, saturday = 6, sunday = 7
        
        //0 for alarm day is Monday alarm
        if arrayDaysOfWeek[0] != " " && currentDay == 2 {
            //ios uses 2 for Monday
            dates[2] = 2
        }
        
        //1 for alarm day is Tuesday alarm
        if arrayDaysOfWeek[1] != " " && currentDay == 3 {
            //ios uses 3 for Tuesday
            dates[3] = 3
        }

        //2 for alarm day is Wednesday alarm
        if arrayDaysOfWeek[2] != " " && currentDay == 4 {
            //ios uses 4 for Wednesday
            dates[4] = 4
        }
        
        //3 for alarm day is Thursday alarm
        if arrayDaysOfWeek[3] != " " && currentDay == 5 {
            //ios uses 5 for Thursday
            dates[5] = 5
        }
         
        //4 for alarm day is Friday alarm
        if arrayDaysOfWeek[4] != " " && currentDay == 6 {
            //ios uses 6 for Friday
            dates[6] = 6
        }
        
        //5 for alarm day is Saturday alarm
        if arrayDaysOfWeek[5] != " " && currentDay == 7 {
            //ios uses 7 for Saturday
            dates[7] = 7
        }
       
        //6 for alarm day is Sunday alarm
        if arrayDaysOfWeek[6] != " " && currentDay == 1 {
            //ios uses 1 for Sunday
            dates[1] = 1
        }
        
        return dates
        
    }

    func setDaysofWeek (selectedDays: String) -> [daysOfWeek] {
        
        var listDays = [daysOfWeek]()
        
        let items = ["Every Monday", "Every Tuesday", "Every Wednesday", "Every Thursday", "Every Friday", "Every Saturday", "Every Sunday"]
        
        let selectedDaysArray = convertStringToCharArray(alarmDays: selectedDays)
        
        //var index = 0
        
        listDays.append(daysOfWeek())
        listDays[0].name = items[0]
        if selectedDaysArray[0] == "M" {
            listDays[0].isSelected = true
        } else if selectedDaysArray[0] != "M" {
            listDays[0].isSelected = false
        }

        listDays.append(daysOfWeek())
        listDays[1].name = items[1]
        if selectedDaysArray[1] == "T" {
            listDays[1].isSelected = true
        } else if selectedDaysArray[1] != "T" {
            listDays[1].isSelected = false
        }
        
        listDays.append(daysOfWeek())
        listDays[2].name = items[2]
        if selectedDaysArray[2] == "W" {
            listDays[2].isSelected = true
        } else if selectedDaysArray[2] != "W" {
            listDays[2].isSelected = false
        }
        
        listDays.append(daysOfWeek())
        listDays[3].name = items[3]
        if selectedDaysArray[3] == "T" {
            listDays[3].isSelected = true
        } else if selectedDaysArray[3] != "T" {
            listDays[3].isSelected = false
        }
        
        listDays.append(daysOfWeek())
        listDays[4].name = items[4]
        if selectedDaysArray[4] == "F" {
            listDays[4].isSelected = true
        } else if selectedDaysArray[4] != "F" {
            listDays[4].isSelected = false
        }
        
        listDays.append(daysOfWeek())
        listDays[5].name = items[5]
        if selectedDaysArray[5] == "S" {
            listDays[5].isSelected = true
        } else if selectedDaysArray[5] != "S" {
            listDays[5].isSelected = false
        }
        
        listDays.append(daysOfWeek())
        listDays[6].name = items[6]
        if selectedDaysArray[6] == "S" {
            listDays[6].isSelected = true
        } else if selectedDaysArray[6] != "S" {
            listDays[6].isSelected = false
        }
        
        
        return listDays
    }

    func convertStringToCharArray(alarmDays: String) -> [String] {
        
        var arrayOfChars = ["","","","","","",""]
        
        for (index, char) in alarmDays.enumerated() {
            
            if index == 0 {
                //Monday Character
                if char == "M" {
                    arrayOfChars[0] = "M"
                }
                else {
                    arrayOfChars[0] = " "
                }
            }
            else if index == 1 {
                //Tuesday Character
                if char == "T" {
                    arrayOfChars[1] = "T"
                }
                else {
                    arrayOfChars[1] = " "
                }
            }
            else if index == 2 {
                //Wednesday Character
                if char == "W" {
                    arrayOfChars[2] = "W"
                }
                else {
                    arrayOfChars[2] = " "
                }
            }
            else if index == 3 {
                //Thursday Character
                if char == "T" {
                    arrayOfChars[3] = "T"
                }
                else {
                    arrayOfChars[3] = " "
                }
            }
            else if index == 4 {
                //Friday Character
                if char == "F" {
                    arrayOfChars[4] = "F"
                }
                else {
                    arrayOfChars[4] = " "
                }
            }
            else if index == 5 {
                //Saturday Character
                if char == "S" {
                    arrayOfChars[5] = "S"
                }
                else {
                    arrayOfChars[5] = " "
                }
            }
            else if index == 6 {
                //Sunday Character
                if char == "S" {
                    arrayOfChars[6] = "S"
                }
                else {
                    arrayOfChars[6] = " "
                }
            }
            
        }
        
        return arrayOfChars
    }

    func selectedDaysWeekToString(selectedDays: [daysOfWeek]) -> String {
        //pass through a string of format "MTWTFSS" for days selected or "_" for unselected days
        //e.g. "MTWTF__" means monday to friday, but not saturday or sunday
        //so this will combine an array of strings into 1 string
        var returnString = ""
        
        //Monday index
        if selectedDays[0].isSelected == true {
            returnString.append("M")
        } else if selectedDays[0].isSelected != true {
            returnString.append("_")
        }

        //Tuesday index
        if selectedDays[1].isSelected == true {
            returnString.append("T")
        } else if selectedDays[1].isSelected != true{
            returnString.append("_")
        }

        //Wednesday index
        if selectedDays[2].isSelected == true {
            returnString.append("W")
        } else if selectedDays[2].isSelected != true {
            returnString.append("_")
        }
        
        //Thursday index
        if selectedDays[3].isSelected == true {
            returnString.append("T")
        } else if selectedDays[3].isSelected != true {
            returnString.append("_")
        }
        
        //Friday index
        if selectedDays[4].isSelected == true {
            returnString.append("F")
        } else if selectedDays[4].isSelected != true {
            returnString.append("_")
        }
        
        //Saturday index
        if selectedDays[5].isSelected == true {
            returnString.append("S")
        } else if selectedDays[5].isSelected != true {
            returnString.append("_")
        }
        
        //Sunday index
        if selectedDays[6].isSelected == true {
            returnString.append("S")
        } else if selectedDays[6].isSelected != true {
            returnString.append("_")
        }
        
        return returnString
        
    }
    
    func convertStringToDate(time: String) -> Date {
    
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "HH:mm"
        let convertedDate = dateFormatter1.date(from: time)!
        
        //print(convertedDate)
        return convertedDate
        
    }
    
// MARK: Save Image Functions and Classes
    
    func saveImage(saveImageName: String) {
        
        let url = NSURL(string: Constants.imageHostURL + saveImageName)! as URL
        if let imageData: NSData = NSData(contentsOf: url) {
            let inputImage = UIImage(data:imageData as Data)!
            
            let imageSaver = ImageSaver()
            imageSaver.writeToPhotoAlbum(image: inputImage)
            
        }
    }
    
    class ImageSaver: NSObject {
        func writeToPhotoAlbum (image: UIImage) {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
        }
        
        @objc func saveError (_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            print("Save Finished!")
        }
        
    }
    
}

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        return true
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        //print (userInfo)
        
        completionHandler([.list, .sound, .banner])
        
    }
    
    func userNotificationCenter(_ _center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        //print("Tap on forgraound app", userInfo)
        //doesn't do anything yet
        
        if let customData = userInfo["customData"] as? String {
            //print("Custom data received: \(customData)")
            print("\(userInfo)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                print("Default Identifier")
            case "show":
                print("clicked on tell me more")
                
                //randMeme()
                break
                
            default:
                break
            }
        }
        
        completionHandler()
        
        
        
    }
    
}
