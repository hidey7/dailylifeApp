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
    
    
    @IBAction func presentData(_ sender: Any) {
        
        let realm = try! Realm()
        let dailyDatas = realm.objects(DailyData.self)
        print(dailyDatas)
        
    }
    
    
}
