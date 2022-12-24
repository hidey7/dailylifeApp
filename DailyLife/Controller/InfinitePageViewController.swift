//
//  InfinitePageViewController.swift
//  DailyLife
//
//  Created by 始関秀弥 on 2022/12/20.
//

import UIKit
import RealmSwift
import PhotosUI

class InfinitePageViewController: UIPageViewController {
    
    private var vcList: [UIViewController] = []
    var daysNumberFromToday = 0
    var currentIndex = 0
    var isEditMode = false
    var currentText = String()
    var idString = String()
    
    let defaultImage = UIImage(named: "selectPhoto")
    
    var nowDateString = String()
    
    let realm = try! Realm()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let tapGestureRecognizer = self.gestureRecognizers.filter{ $0 is UITapGestureRecognizer }.first as! UITapGestureRecognizer
        tapGestureRecognizer.isEnabled = false
        
        self.initPageViewController()
        setupNavigationbar()

    }
    
    private func initPageViewController() {
        
        let firstVC = storyboard?.instantiateViewController(withIdentifier: "MainVC") as! MainViewController
        let secondVC = storyboard?.instantiateViewController(withIdentifier: "MainVC") as! MainViewController
        let thirdVC = storyboard?.instantiateViewController(withIdentifier: "MainVC") as! MainViewController
        
        firstVC.delegate = self
        secondVC.delegate = self
        thirdVC.delegate = self
        
        let vcList = [firstVC, secondVC, thirdVC]
        
        setNowDateString()
        firstVC.dateString = nowDateString
        secondVC.dateString = nowDateString
        thirdVC.dateString = nowDateString
        
        changeDateLabelTextAndMemoryImage(nextVC: firstVC)
        
        self.vcList = vcList
        self.setViewControllers([self.vcList[0]], direction: .forward, animated: true)
        self.dataSource = self
        
    }
    
    private func setupNavigationbar() {
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "次の日", style: .plain, target: self, action: #selector(rightBarButtonItemTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "前の日", style: .plain, target: self, action: #selector(leftBarButtonItemTapped))
        navigationItem.title = nil
        
    }
    
    @objc func rightBarButtonItemTapped() {

        
        if isEditMode == false {
            //次の日ボタン押下時
            daysNumberFromToday += 1
            setNowDateString()
            currentIndex = (currentIndex + 1) % 3
            let nextIndex = currentIndex
            let nextVC = self.vcList[nextIndex] as! MainViewController
            nextVC.dateString = self.nowDateString
            changeDateLabelTextAndMemoryImage(nextVC: nextVC)
            self.setViewControllers([nextVC], direction: .forward, animated: true)
            
        } else {
            //保存ボタン押下時
            saveDataWithRealm()
            savePhoto()
            navigationItem.titleView = nil
            isEditMode = false
            switchSwipeIsEnable()
            let currentVC = vcList[currentIndex] as! MainViewController
            currentVC.sentenceTextView.resignFirstResponder()
            currentVC.sentenceTextView.isEditable = false
            currentVC.toolBarButtonItem.title = "編集"
            
            navigationItem.rightBarButtonItem?.title = "次の日"
            navigationItem.leftBarButtonItem?.title = "前の日"
            navigationItem.leftBarButtonItem?.tintColor = .tintColor
        }
        
    }
    
    @objc func leftBarButtonItemTapped() {
       
        
        let currentVC = vcList[currentIndex] as! MainViewController
        
        if isEditMode == false {
            daysNumberFromToday -= 1
            setNowDateString()
            currentIndex = (currentIndex - 1 + 3) % 3
            let nextIndex = currentIndex
            let nextVC = self.vcList[nextIndex] as! MainViewController
            nextVC.dateString = self.nowDateString
            changeDateLabelTextAndMemoryImage(nextVC: nextVC)
            self.setViewControllers([nextVC], direction: .reverse, animated: true)
        } else {
            //キャンセルボタン押下時
            isEditMode = false
            switchSwipeIsEnable()
            currentVC.sentenceTextView.resignFirstResponder()
            currentVC.sentenceTextView.isEditable = false
            currentVC.toolBarButtonItem.title = "編集"
            currentVC.sentenceTextView.hidePlaceHolder()
            currentVC.sentenceTextView.text = currentText
            
            self.navigationItem.titleView = nil
            self.navigationItem.rightBarButtonItem?.title = "次の日"
            self.navigationItem.leftBarButtonItem?.title = "前の日"
            self.navigationItem.leftBarButtonItem?.tintColor = .tintColor
        }
        
    }
    
    private func switchSwipeIsEnable() {
        // swipeによるページめくりを担当するインスタンスを取得
        let panGestureRecognizer = self.gestureRecognizers.filter{ $0 is UIPanGestureRecognizer }.first as! UIPanGestureRecognizer
        if isEditMode {
            panGestureRecognizer.isEnabled = false
            return
        }
        panGestureRecognizer.isEnabled = true
        
    }
    
    private func changeDateLabelTextAndMemoryImage(nextVC: MainViewController) {
        
        let today = Date()
        let modifiedDate = Calendar.current.date(byAdding: .day, value: daysNumberFromToday, to: today)
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .long
        setIdString(modifiedDate: modifiedDate!)
        nextVC.photo = getMemoryImage()
        
        if realm.object(ofType: DailyData.self, forPrimaryKey: idString) == nil {
            nextVC.sentence = nil
        } else {
            let savedData = realm.object(ofType: DailyData.self, forPrimaryKey: idString)
            nextVC.dateString = savedData!.date
            nextVC.sentence = savedData?.sentence
        }
        
    }
    
    private func getMemoryImage() -> UIImage {
        
        let path = getFileURL().path()
        if FileManager.default.fileExists(atPath: path) {
            if let imageData = UIImage(contentsOfFile: path) {
                return imageData
            } else {
                print("Failed to load the image.")
            }
        }
        return defaultImage!
    }
    
    private func getFileURL() -> URL {
        
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDir.appendingPathComponent("\(idString).png")
        
    }
    
    private func setIdString(modifiedDate: Date) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .long
        dateFormatter.dateFormat = "yyyyMd"
        self.idString = dateFormatter.string(from: modifiedDate)
        
    }
    
    private func setNowDateString() {
        
        let today = Date()
        let modifiedDate = Calendar.current.date(byAdding: .day, value: daysNumberFromToday, to: today)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale(identifier: "ja_JP")
        self.nowDateString = dateFormatter.string(from: modifiedDate!)
        
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

extension InfinitePageViewController: MainViewControllerDelegate {
    
    func mainViewControllerToolbarCenterButtonTapped() {
        
        let currentVC = vcList[currentIndex] as! MainViewController
        if isEditMode == false {
            //編集ボタン押下後
            if let dateSentence = currentVC.sentenceTextView.text {
                self.currentText = dateSentence
            }
            let photoSelectButton = UIButton(type: .system)
            photoSelectButton.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
            photoSelectButton.backgroundColor = UIColor.clear
            photoSelectButton.setTitle("写真を選択", for: .normal)
            photoSelectButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
            photoSelectButton.setTitleColor(UIColor.tintColor, for: .normal)
            photoSelectButton.addTarget(self, action: #selector(toolbarCenterButtonTapped), for: .touchUpInside)
            self.navigationItem.titleView = photoSelectButton
            currentVC.toolBarButtonItem.title = "保存"
            navigationItem.rightBarButtonItem?.title = "保存"
            navigationItem.leftBarButtonItem?.title = "キャンセル"
            navigationItem.leftBarButtonItem?.tintColor = .red
            isEditMode = true
            switchSwipeIsEnable()
            currentVC.sentenceTextView.isEditable = true
            currentVC.sentenceTextView.becomeFirstResponder()
        } else {
            //保存ボタン押下時
            saveDataWithRealm()
            savePhoto()
            navigationItem.titleView = nil
            isEditMode = false
            switchSwipeIsEnable()
            currentVC.toolBarButtonItem.title = "編集"
            navigationItem.rightBarButtonItem?.title = "次の日"
            navigationItem.leftBarButtonItem?.title = "前の日"
            navigationItem.leftBarButtonItem?.tintColor = .tintColor
            currentVC.sentenceTextView.isEditable = false
            currentVC.sentenceTextView.resignFirstResponder()
        }
        
    }
    
    @objc func saveDataWithRealm() {
        
        let currentVC = self.vcList[currentIndex] as! MainViewController
        let dailyData = DailyData(date: currentVC.dateLabel.text!, sentence: currentVC.sentenceTextView.text, id: idString)
        if currentVC.sentenceTextView.text.isEmpty == false && realm.object(ofType: DailyData.self, forPrimaryKey: idString) == nil {
            try! realm.write {
                realm.add(dailyData) //保存
                print("保存！")
            }
        } else {
            let savedData = realm.object(ofType: DailyData.self, forPrimaryKey: idString)
            try! realm.write {
                savedData?.sentence = currentVC.sentenceTextView.text //更新
                print("更新！")
            }
        }
        
    }
    
    
    
    private func savePhoto() {
        
        let currentVC = self.vcList[currentIndex] as! MainViewController
        let imageView = currentVC.memoryImageView
        if imageView!.image != defaultImage && imageView?.image != nil {
            let imageData = imageView?.image?.pngData()
            do {
                try imageData?.write(to: getFileURL())
            } catch {
                print("Failed to save the image:", error)
            }
        }
        
    }
    
    @objc func toolbarCenterButtonTapped() {
        
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
        
    }
    
}

extension InfinitePageViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        if let firstItemProvider = results.first?.itemProvider {
            if firstItemProvider.canLoadObject(ofClass: UIImage.self) {
                firstItemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let firstImage = image as? UIImage, let safeSelf = self {
                        DispatchQueue.main.async {
                            let currentVC = safeSelf.vcList[safeSelf.currentIndex] as! MainViewController
                            currentVC.memoryImageView.image = firstImage
                        }
                    }
                }
            }
        }
        
    }
    
}


extension InfinitePageViewController: UIPageViewControllerDataSource {
    
    //左にスワイプ(進む)
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        //1日前
        daysNumberFromToday -= 1
        setNowDateString()
        let nowIndex = self.vcList.firstIndex(of: viewController)
        let nextIndex = (nowIndex! + 1) % 3
        let nextVC = self.vcList[nextIndex] as! MainViewController
        nextVC.dateString = self.nowDateString
        changeDateLabelTextAndMemoryImage(nextVC: nextVC)
        self.currentIndex = nextIndex
        return nextVC
    }
    
    //右にスワイプ(戻る)
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //1日後
        daysNumberFromToday += 1
        setNowDateString()
        let nowIndex = self.vcList.firstIndex(of: viewController)
        let backIndex = (nowIndex! - 1 + 3) % 3
        let backVC = self.vcList[backIndex] as! MainViewController
        backVC.dateString = self.nowDateString
        changeDateLabelTextAndMemoryImage(nextVC: backVC)
        self.currentIndex = backIndex
        return backVC
    }
    
}


