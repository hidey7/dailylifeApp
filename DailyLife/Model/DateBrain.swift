import Foundation


struct DateBrain {
    
    private var daysCountFromToday = 0
    private var today = Date()
    private var dateFormatter = DateFormatter()
    
    func setNowDateString() -> String {
        
        let modifiedDate = Calendar.current.date(byAdding: .day, value: daysCountFromToday, to: today)
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: "ja_JP")
        return dateFormatter.string(from: modifiedDate!)
        
    }
    
    func setIdString() -> String {
        
        let modifiedDate = Calendar.current.date(byAdding: .day, value: daysCountFromToday, to: today)
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .long
        dateFormatter.dateFormat = "yyyyMd"
        return dateFormatter.string(from: modifiedDate!)
        
    }
    
    func getDaysNumberFromToday() -> Int {
        return daysCountFromToday
    }
    
    mutating func restoreDaysNumberFromToday(_ previousValue: Int) {
        self.daysCountFromToday = previousValue
    }
    
    mutating func incrementDaysNumberFromToday() {
        self.daysCountFromToday += 1
    }
    
    mutating func decrementDaysNumberFromToday() {
        self.daysCountFromToday -= 1
    }
    
}
