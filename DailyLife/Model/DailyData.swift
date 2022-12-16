//
//  DailyData.swift
//  DailyLife
//
//  Created by 始関秀弥 on 2022/12/12.
//

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
