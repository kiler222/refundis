import UIKit
import BarcodeScanner
import FirebaseAuth

final class ViewController: UIViewController {
//  @IBOutlet var presentScannerButton: UIButton!
  @IBOutlet var pushScannerButton: UIButton!

//  @IBAction func handleScannerPresent(_ sender: Any, forEvent event: UIEvent) {
//    let viewController = makeBarcodeScannerViewController()
//    viewController.title = "Skaner"
//    present(viewController, animated: true, completion: nil)
//  }

    @IBOutlet weak var manualInputButton: UIButton!
    
    @IBAction func manualInputButton(_ sender: Any) {
        let viewController = ManualInputViewController()
        viewController.title = "WPROWADŹ DANE"
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    
    @IBAction func handleScannerPush(_ sender: Any, forEvent event: UIEvent) {
        let viewController = makeBarcodeScannerViewController()
        viewController.title = "SKANUJ KARTĘ POKŁADOWĄ"
        navigationController?.pushViewController(viewController, animated: true)
    }

    
    override func viewDidLoad() {
        
        Auth.auth().signInAnonymously() { (authResult, error) in
            if error == nil {
                let user = authResult!.user
//                let isAnonymous = user.isAnonymous  // true
                let uid = user.uid
                
                print("PJ zalogowany: \(user), \(uid)")
            } else {
                print("Błąd logowania: \(String(describing: error?.localizedDescription))")
            }
        }
        
        
        manualInputButton.layer.cornerRadius = 5
        manualInputButton.clipsToBounds = false
        manualInputButton.layer.shadowColor = UIColor.black.cgColor
        manualInputButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        manualInputButton.layer.shadowOpacity = 0.7
        manualInputButton.layer.shadowRadius = 4.0
        manualInputButton.titleLabel?.textAlignment = NSTextAlignment.center
        
        
        pushScannerButton.layer.cornerRadius = 5
        pushScannerButton.clipsToBounds = false
        pushScannerButton.layer.shadowColor = UIColor.black.cgColor
        pushScannerButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        pushScannerButton.layer.shadowOpacity = 0.7
        pushScannerButton.layer.shadowRadius = 4.0
        pushScannerButton.titleLabel?.textAlignment = NSTextAlignment.center
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        // needed to clear the text in the back navigation:
        self.navigationItem.title = " "
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationItem.title = "REFUNDIS"
        
    }

    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.value(forKey: "tutorialShowed") == nil {
            if let onboardingVC = self.storyboard?.instantiateViewController(withIdentifier: "OnboardingViewController") {
                onboardingVC.providesPresentationContextTransitionStyle = true
                onboardingVC.definesPresentationContext = true
                onboardingVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
                self.present(onboardingVC, animated: true, completion: nil)
            }
        }
    }
    
  private func makeBarcodeScannerViewController() -> BarcodeScannerViewController {
    let viewController = BarcodeScannerViewController()
    viewController.codeDelegate = self
    viewController.errorDelegate = self
    viewController.dismissalDelegate = self
    return viewController
  }
}

// MARK: - BarcodeScannerCodeDelegate

extension ViewController: BarcodeScannerCodeDelegate {
  func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
    print("Barcode Data: \(code)")
    

//    print("Symbology Type: \(type)")
    let sIndex = code.startIndex

    if (String(code[sIndex]) == "M" && code.count >= 60 ) {
            let fullName = code[code.index(sIndex, offsetBy: 2) ... code.index(sIndex, offsetBy: 21)]
            let fullNameArray = fullName.components(separatedBy: "/")
            let firstName = fullNameArray[1]
            let lastName = fullNameArray[0]
            let PNR = code[code.index(sIndex, offsetBy: 23) ... code.index(sIndex, offsetBy: 29)]
            let origin = code[code.index(sIndex, offsetBy: 30) ... code.index(sIndex, offsetBy: 32)]
            let destination = code[code.index(sIndex, offsetBy: 33) ... code.index(sIndex, offsetBy: 35)]
            let airline = code[code.index(sIndex, offsetBy: 36) ... code.index(sIndex, offsetBy: 38)]
            let flight = code[code.index(sIndex, offsetBy: 39) ... code.index(sIndex, offsetBy: 43)]
            let fligtNumber = "\(airline) \(flight)"
            let julianDate = code[code.index(sIndex, offsetBy: 44) ... code.index(sIndex, offsetBy: 46)]
        
        
            let boardingPass : [String : Any] = ["firstName" : firstName,
                                                    "lastName" : lastName,
                                                    "origin" : String(origin),
                                                    "destination" : String(destination),
                                                    "flightNumber" : fligtNumber,
                                                    "PNR" : String(PNR),
                                                    "julianDate" : Int(julianDate)!
                
            ]
        
        
               controller.resetWithError(message: "")
//        controller.reset()
        
        
        
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ScannerInputViewController") as! ScannerInputViewController
            viewController.title = "ZWERYFIKUJ DANE"
            viewController.boardingPass = boardingPass
            navigationController?.pushViewController(viewController, animated: true)
        
        
    } else {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            controller.resetWithError()
            
        }
        
    }
    
    
    }
}

// MARK: - BarcodeScannerErrorDelegate

extension ViewController: BarcodeScannerErrorDelegate {
  func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
    print(error)
  }
}

// MARK: - BarcodeScannerDismissalDelegate

extension ViewController: BarcodeScannerDismissalDelegate {
  func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
    controller.dismiss(animated: true, completion: nil)
  }
}

extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
            "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
            "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
