//
//  MainViewController.swift
//  DailyLife
//
//  Created by 始関秀弥 on 2022/12/18.
//

import UIKit
import RealmSwift
import PhotosUI

protocol MainViewControllerDelegate {
    func mainViewControllerToolbarCenterButtonTapped()
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sentenceTextView: PlaceTextView!
    
    @IBOutlet weak var toolBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var memoryImageView: UIImageView!
    
    var delegate: MainViewControllerDelegate?
    
    var dateString = String()
    
    var photo: UIImage?
    
    var sentence: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dateLabel.text = dateString
        
        if let sentence = sentence {
            self.sentenceTextView.text = sentence
            self.sentenceTextView.hidePlaceHolder()
        } else {
            self.sentenceTextView.text = ""
            self.sentenceTextView.presentPlaceHolder()
            self.sentenceTextView.placeHolder = "今日は\(dateString)です。"
        }
             
        if let image = photo {
            self.memoryImageView.image = image
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.sentenceTextView.resignFirstResponder()
    }
    
    
    @IBAction func toolBarItemTapped(_ sender: UIBarButtonItem) {
        
        delegate?.mainViewControllerToolbarCenterButtonTapped()
        
    }
    
    @objc func centerNavigationItemTapped() {
        
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
        
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

extension MainViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        if let firstItemProvider = results.first?.itemProvider {
            if firstItemProvider.canLoadObject(ofClass: UIImage.self) {
                firstItemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    if let firstImage = image as? UIImage, let safeSelf = self {
                        DispatchQueue.main.async {
                            safeSelf.memoryImageView.image = firstImage
                        }
                    }
                }
            }
        }

    }

}
