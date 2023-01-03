import UIKit
import RealmSwift
import PhotosUI

class InfinitePageViewController: UIPageViewController {
    
    private var vcList: [UIViewController] = []
    var currentIndex = 0
    var isEditMode = false
    var currentText = String()
    var idString = String()
    
    
    let realm = try! Realm()
    
    var justBeforeDaysCountFromToday = Int()
    
    var dailyBrain = DailyBrain()
    var dateBrain = DateBrain()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        firstVC.dateString = dateBrain.setNowDateString()
        secondVC.dateString = dateBrain.setNowDateString()
        thirdVC.dateString = dateBrain.setNowDateString()
        
        changeDateLabelTextAndMemoryImage(nextVC: firstVC)
        
        self.vcList = vcList
        self.setViewControllers([self.vcList[0]], direction: .forward, animated: true)
        self.dataSource = self
        self.delegate = self
        
    }
    
    private func setupNavigationbar() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "次の日", style: .plain, target: self, action: #selector(rightBarButtonItemTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "前の日", style: .plain, target: self, action: #selector(leftBarButtonItemTapped))
        navigationItem.title = nil
        
    }
    
    @objc func rightBarButtonItemTapped() {

        
        if isEditMode == false {
            //次の日ボタン押下時
            dateBrain.incrementDaysNumberFromToday()
            currentIndex = (currentIndex + 1) % 3
            let nextIndex = currentIndex
            let nextVC = self.vcList[nextIndex] as! MainViewController
            nextVC.dateString = dateBrain.setNowDateString()
            changeDateLabelTextAndMemoryImage(nextVC: nextVC)
            self.setViewControllers([nextVC], direction: .forward, animated: true)
            
        } else {
            //保存ボタン押下時
            saveData()
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
            dateBrain.decrementDaysNumberFromToday()
            currentIndex = (currentIndex - 1 + 3) % 3
            let nextIndex = currentIndex
            let nextVC = self.vcList[nextIndex] as! MainViewController
            nextVC.dateString = dateBrain.setNowDateString()
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
        
        self.idString = dateBrain.setIdString()
        nextVC.photo = dailyBrain.getMemoryImage(self.idString)
        
        guard let savedData = dailyBrain.getDailyData(nextVC, self.idString) else {
            nextVC.sentence = nil
            return
        }
        
        nextVC.dateString = savedData.date
        nextVC.sentence = savedData.sentence
       
    }
    
    
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
            saveData()
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
    
    @objc func saveData() {
        
        let currentVC = self.vcList[currentIndex] as! MainViewController
        let dailyData = DailyData(date: currentVC.dateLabel.text!, sentence: currentVC.sentenceTextView.text, id: idString)
        if currentVC.sentenceTextView.text.isEmpty == false {
            dailyBrain.saveDailyData(dailyData, self.idString)
        }
        
    }
    
    
    
    private func savePhoto() {
        
        let currentVC = self.vcList[currentIndex] as! MainViewController
        let imageView = currentVC.memoryImageView
        if let image = imageView?.image {
            dailyBrain.savePhoto(image, self.idString)
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
        justBeforeDaysCountFromToday = dateBrain.getDaysNumberFromToday()
        dateBrain.decrementDaysNumberFromToday()
        let nowIndex = self.vcList.firstIndex(of: viewController)
        let nextIndex = (nowIndex! + 1) % 3
        let nextVC = self.vcList[nextIndex] as! MainViewController
        nextVC.dateString = dateBrain.setNowDateString()
        changeDateLabelTextAndMemoryImage(nextVC: nextVC)
        self.currentIndex = nextIndex
        return nextVC
    }
    
    //右にスワイプ(戻る)
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //1日後
        justBeforeDaysCountFromToday = dateBrain.getDaysNumberFromToday()
        dateBrain.incrementDaysNumberFromToday()
        let nowIndex = self.vcList.firstIndex(of: viewController)
        let backIndex = (nowIndex! - 1 + 3) % 3
        let backVC = self.vcList[backIndex] as! MainViewController
        backVC.dateString = dateBrain.setNowDateString()
        changeDateLabelTextAndMemoryImage(nextVC: backVC)
        self.currentIndex = backIndex
        return backVC
    }
    
}


extension InfinitePageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if !completed {
            dateBrain.restoreDaysNumberFromToday(justBeforeDaysCountFromToday)
        }
        
    }
    
}
