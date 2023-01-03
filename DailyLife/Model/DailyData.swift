import Foundation
import RealmSwift

class DailyData: Object {
    
    @Persisted var date: String = ""
    @Persisted var sentence: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    @Persisted(primaryKey: true) var id: String = ""
    
    convenience init(date: String, sentence: String, id: String) {
        self.init()
        self.date = date
        self.sentence = sentence
        self.id = id
    }
    
}
