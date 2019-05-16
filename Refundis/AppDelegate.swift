import UIKit
import BarcodeScanner
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    let navigationBarAppearace = UINavigationBar.appearance()
    
    navigationBarAppearace.barTintColor = UIColor(red: 232.0/255.0, green: 79.0/255.0, blue: 46.0/255.0, alpha: 0.2)
    navigationBarAppearace.tintColor = .white//uicolorFromHex(0x034517)
    navigationBarAppearace.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
    navigationBarAppearace.isTranslucent = true
    
    FirebaseApp.configure()
    

    
    return true
  }
}
