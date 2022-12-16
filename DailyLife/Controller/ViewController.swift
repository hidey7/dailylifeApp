//
//  ViewController.swift
//  DailyLife
//
//  Created by 始関秀弥 on 2022/12/10.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var sentenceTextView: UITextView!
    
    var daysNumberFromToday = 0
    
    var idString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        //        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        //        dateLabel.text = "\(dateComponents.year!)年\(dateComponents.month!)月\(dateComponents.day!)日"
        //        sentenceTextView.text = "ここに文書を書きます。"
        changeDateLabelText()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.sentenceTextView.resignFirstResponder()
        
        let realm = try! Realm()
        let dailyDatas = realm.objects(DailyData.self)
        print(dailyDatas)
        
    }
    
    
    @IBAction func saveData(_ sender: Any) {
        
        let realm = try! Realm()
        let dailyData = DailyData(date: dateLabel.text!, sentence: sentenceTextView.text!, id: idString)
        if realm.object(ofType: DailyData.self, forPrimaryKey: idString) == nil {
            try! realm.write {
                realm.add(dailyData)
            }
            print("保存したよ!")
        } else {
            let savedData = realm.object(ofType: DailyData.self, forPrimaryKey: idString)
            try! realm.write {
                savedData?.sentence = sentenceTextView.text!
            }
            print("変更したよ！")
        }
        
    }
    
    private func changeDateLabelText() {
        
        let today = Date()
        let modifiedDate = Calendar.current.date(byAdding: .day, value: daysNumberFromToday, to: today)
        setIdString(modifiedDate: modifiedDate!)
        
        let realm = try! Realm()
        if realm.object(ofType: DailyData.self, forPrimaryKey: idString) == nil {
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            dateFormatter.locale = Locale(identifier: "ja_JP")
            dateFormatter.dateStyle = .long
            let nextDateString = dateFormatter.string(from: modifiedDate!)
            dateLabel.text = nextDateString
            sentenceTextView.text = "今日は\(nextDateString)です"
        } else {
            let savedData = realm.object(ofType: DailyData.self, forPrimaryKey: idString)
            dateLabel.text = savedData?.date
            sentenceTextView.text = savedData?.sentence
        }
        
    }
    
    private func setIdString(modifiedDate: Date) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .long
        dateFormatter.dateFormat = "yyyyMd"
        self.idString = dateFormatter.string(from: modifiedDate)
        
    }
    
    
    @IBAction func moveToNextDay(_ sender: Any) {
        daysNumberFromToday += 1
        changeDateLabelText()
    }
    
    @IBAction func backToTheDayBefore(_ sender: Any) {
        daysNumberFromToday -= 1
        changeDateLabelText()
    }
    
    
    
}

