import UIKit
import RealmSwift
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var url:NSURL?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics()])
        return true
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool
    {
        self.url = url
        showAlertToMergeExpenses()
        return true
    }
    
    private func showAlertToMergeExpenses(){
        var alert = UIAlertController(title: "attention".localized, message: "merge_warning".localized, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .Cancel, handler: { (action:UIAlertAction!) -> Void in
            self.removeImportedFile()
        }))
        alert.addAction(UIAlertAction(title: "ok".localized, style: .Default, handler: { (action:UIAlertAction!) -> Void in
            self.overwrite()
            self.removeImportedFile()
            Answers.logCustomEventWithName("Expenses Imported", customAttributes:  nil)
        }))
        if let rootVC = self.window?.rootViewController {
            rootVC.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    private func overwrite(){
        let defaultPath = Realm().path
        let importedPath = defaultPath + ".imported"
        
        if let path = url?.path {
            let fileManager = NSFileManager.defaultManager()
            fileManager.removeItemAtPath(importedPath, error: nil)
            fileManager.copyItemAtPath(path, toPath: importedPath, error: nil)
            let importedRealm = Realm(path: importedPath)
            let importedExpenses = importedRealm.objects(Expense)
            RealmUtilities.updateEntries(importedExpenses)
        }
    }
    
    private func removeImportedFile(){
        let fileManager = NSFileManager()
        if let path = url?.path {
            fileManager.removeItemAtPath(path, error: nil)
        }
    }
}