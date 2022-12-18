//
//  MainViewController.swift
//  DailyLife
//
//  Created by 始関秀弥 on 2022/12/18.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sentenceTextView: PlaceTextView!
    
    @IBOutlet weak var toolBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var memoryImageView: UIImageView!
    
    var daysNumberFromToday = 0
    var idString = String()
    
    var isEditMode = false
    
    let defaultImage = UIImage(named: "selectPhoto")
    
    var currentText = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        overrideUserInterfaceStyle = .light
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "次の日", style: .plain, target: self, action: #selector(rightBarButtonItemTapped))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "前の日", style: .plain, target: self, action: #selector(leftBarButtonItemTapped))
        
        changeDateLabelText()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.sentenceTextView.resignFirstResponder()
        print(sentenceTextView.text.isEmpty)
    }
    
    @objc func rightBarButtonItemTapped() {
        
        if isEditMode == false {
            daysNumberFromToday += 1
            changeDateLabelText()
        } else {
            //保存ボタン押下時
            saveData()
            navigationItem.titleView = nil
            print("rightBarButton保存！")
            isEditMode = false
            sentenceTextView.resignFirstResponder()
            sentenceTextView.isEditable = false
            toolBarButtonItem.title = "編集"
            self.navigationItem.rightBarButtonItem?.title = "次の日"
            self.navigationItem.leftBarButtonItem?.isHidden = false
        }
        
    }
    
    @objc func leftBarButtonItemTapped() {
        
        if isEditMode == false {
            daysNumberFromToday -= 1
            changeDateLabelText()
        } else {
            //キャンセルボタン押下時
            isEditMode = false
            sentenceTextView.resignFirstResponder()
            sentenceTextView.isEditable = false
            toolBarButtonItem.title = "編集"
            self.navigationItem.titleView = nil
            self.navigationItem.rightBarButtonItem?.title = "次の日"
            self.navigationItem.leftBarButtonItem?.title = "前の日"
            self.navigationItem.leftBarButtonItem?.tintColor = .tintColor
            self.sentenceTextView.text = currentText
        }
        
    }
    
    private func changeDateLabelText() {
        
        let today = Date()
        let modifiedDate = Calendar.current.date(byAdding: .day, value: daysNumberFromToday, to: today)
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .long
        let dateString = dateFormatter.string(from: modifiedDate!)
        setIdString(modifiedDate: modifiedDate!)
        
        let realm = try! Realm()
        if realm.object(ofType: DailyData.self, forPrimaryKey: idString) == nil {
            dateLabel.text = dateString
            sentenceTextView.text = ""
            sentenceTextView.presentPlaceHolder()
            sentenceTextView.placeHolder = "今日は\(dateString)です"
        } else {
            sentenceTextView.hidePlaceHolder()
            sentenceTextView.placeHolder = "今日は\(dateString)です"
            let savedDate = realm.object(ofType: DailyData.self, forPrimaryKey: idString)
            dateLabel.text = savedDate?.date
            sentenceTextView.text = savedDate?.sentence
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
    
    @IBAction func toolBarItemTapped(_ sender: UIBarButtonItem) {
        
        if isEditMode == false {
            //編集ボタン押下時
            if let dateSentence = sentenceTextView.text {
                self.currentText = dateSentence
            }
            let sampleButton = UIButton(type: .system)
            sampleButton.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
            sampleButton.backgroundColor = UIColor.clear
            sampleButton.setTitle("写真を選択", for: .normal)
            sampleButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
            sampleButton.setTitleColor(UIColor.tintColor, for: .normal)
//            sampleButton.layer.cornerRadius = 10
            sampleButton.addTarget(self, action: #selector(centerNavigationItemTapped), for: .touchUpInside)
            
            navigationItem.titleView = sampleButton
            sender.title = "保存"
            self.navigationItem.rightBarButtonItem?.title = "保存"
            self.navigationItem.leftBarButtonItem?.title = "キャンセル"
            self.navigationItem.leftBarButtonItem?.tintColor = .red
            isEditMode = true
            sentenceTextView.isEditable = true
            sentenceTextView.becomeFirstResponder()
        } else {
            //閲覧モード
            saveData()
            navigationItem.titleView = nil
            isEditMode = false
            sender.title = "編集"
            self.navigationItem.rightBarButtonItem?.title = "次の日"
            self.navigationItem.leftBarButtonItem?.isHidden = false
            sentenceTextView.isEditable = false
            sentenceTextView.resignFirstResponder()
        }
    }
    
    @objc func centerNavigationItemTapped() {
        
    }
    
    @objc func saveData() {
        
        let realm = try! Realm()
        let dailyData = DailyData(date: dateLabel.text!, sentence: sentenceTextView.text!, id: idString)
        if sentenceTextView.text.isEmpty == false && realm.object(ofType: DailyData.self, forPrimaryKey: idString) == nil {
            try! realm.write {
                realm.add(dailyData) //保存
            }
        } else {
            let savedData = realm.object(ofType: DailyData.self, forPrimaryKey: idString)
            try! realm.write {
                savedData?.sentence = sentenceTextView.text //更新
            }
        }
        
    }
    
    
    @IBAction func presentData(_ sender: Any) {
        
        let realm = try! Realm()
        let dailyDatas = realm.objects(DailyData.self)
        print(dailyDatas)
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
