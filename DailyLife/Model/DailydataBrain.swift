import Foundation
import RealmSwift

struct DailyBrain {
    
    private let realm = try! Realm()
    private let defaultImage = UIImage(named: "selectPhoto")
    
    
    func getDailyData(_ mainVC: MainViewController, _ idString: String) -> DailyData? {
        
        if realm.object(ofType: DailyData.self, forPrimaryKey: idString) == nil {
            return nil
        }
        return realm.object(ofType: DailyData.self, forPrimaryKey: idString)
        
    }
    
    func getMemoryImage(_ idString: String) -> UIImage {
        
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = docDir.appendingPathComponent("\(idString).png").path()
        if FileManager.default.fileExists(atPath: path) {
            if let imageData = UIImage(contentsOfFile: path) {
                return imageData
            } else {
                print("Failed to load the image.")
            }
        }
        return defaultImage!
        
    }
    
    func savePhoto(_ image: UIImage, _ idString: String) {
        
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = docDir.appendingPathComponent("\(idString).png")
        let imageData = image.pngData()
        do {
            try imageData!.write(to: url)
        } catch {
            print("Failed to save the image:", error)
        }
        
    }
    
    func saveDailyData(_ dailyData: DailyData, _ idString: String) {
        
        if realm.object(ofType: DailyData.self, forPrimaryKey: idString) == nil {
            try! realm.write {
                realm.add(dailyData) //保存
                print("保存")
            }
        } else {
            let savedData = realm.object(ofType: DailyData.self, forPrimaryKey: idString)
            try! realm.write {
                savedData?.sentence = dailyData.sentence //更新
                print("更新")
            }
        }
        
    }
    
    
}
