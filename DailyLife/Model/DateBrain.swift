import Foundation


struct DateBrain {
    
    private var daysNumberFromToday = 0
    private var today = Date()
    private var dateFormatter = DateFormatter()
    
    func setNowDateString() -> String {
        
        let modifiedDate = Calendar.current.date(byAdding: .day, value: daysNumberFromToday, to: today)
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: "ja_JP")
        return dateFormatter.string(from: modifiedDate!)
        
    }
    
    func setIdString() -> String {
        
        let modifiedDate = Calendar.current.date(byAdding: .day, value: daysNumberFromToday, to: today)
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .long
        dateFormatter.dateFormat = "yyyyMd"
        return dateFormatter.string(from: modifiedDate!)
        
    }
    
    func getDaysNumberFromToday() -> Int {
        return daysNumberFromToday
    }
    
    mutating func restoreDaysNumberFromToday(_ previousValue: Int) {
        self.daysNumberFromToday = previousValue
    }
    
    mutating func incrementDaysNumberFromToday() {
        self.daysNumberFromToday += 1
    }
    
    mutating func decrementDaysNumberFromToday() {
        self.daysNumberFromToday -= 1
    }
    
}
