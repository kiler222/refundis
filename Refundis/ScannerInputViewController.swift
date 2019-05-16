//
//  ScannerInputViewController.swift
//  BarcodeScannerExample
//
//  Created by kiler on 16/05/2019.
//  Copyright © 2019 Hyper Interaktiv AS. All rights reserved.
//

import UIKit
import FlagPhoneNumber
import FirebaseFirestore
import SVProgressHUD

class ScannerInputViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var mobile: FPNTextField!
    
    
    @IBAction func checkbox(_ sender: Any) {
        if (isChecked) {
            checkbox.setImage(UIImage(named: "unchecked"), for: .normal)
            isChecked = false
        } else {
            checkbox.setImage(UIImage(named: "checked"), for: .normal)
            isChecked = true
        }
    }
    @IBOutlet weak var checkbox: UIButton!
    @IBOutlet weak var toField: UITextField!
    @IBOutlet weak var fromField: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var flightNumber: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    
    @IBOutlet weak var backgroundView: UIView!
    
    var isPhoneValid = false
    let datePicker = UIDatePicker()
    var boardingPass : [String:Any]!
    var isChecked = false
    
    
    @IBAction func sendButton(_ sender: Any) {
        
        
        
        
        let isEmailOK = emailField.text?.isValidEmail() ?? false
        
        let alertEmail = UIAlertController(title: "Niepoprawny adres email", message: "", preferredStyle: .alert)
        
        let alertMobile = UIAlertController(title: "Niepoprawny numer telefonu", message: "", preferredStyle: .alert)
        
        let alertEmpty = UIAlertController(title: "Uzupełnij pola", message: "", preferredStyle: .alert)
        
        let alertSent = UIAlertController(title: "Przyjęliśmy twoje zgłoszenie", message: "Odezwiemy się do Ciebie wkrótce.", preferredStyle: .alert)
        
          let alertCheckbox = UIAlertController(title: "Prosimy zaakceptować regulamin", message: "", preferredStyle: .alert)
        
        let sentAction = UIAlertAction(title: "OK", style: .default, handler: { (ok) in
            self.dismiss(animated: true)
            self.navigationController?.popToRootViewController(animated: true)
            
        })
        
        alertEmail.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertMobile.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertEmpty.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         alertCheckbox.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alertSent.addAction(sentAction)
        
        //        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        
        
        if (!isEmailOK) {
            print("PJ email niepoprawny albo brak")
            self.present(alertEmail, animated: true)
        } else {
            print("PJ email OK")
        }
        
        if (!isChecked) {
            print("PJ niezaakcepotwany regulamin")
            self.present(alertCheckbox, animated: true)
        } else {
            print("PJ regulamin OK")
        }
        
        if (!isPhoneValid){
            print("PJ mobile niepoprawny ")
            self.present(alertMobile, animated: true)
        } else {
            print("PJ mobile OK")
        }
        
        if (flightNumber.text!.isEmpty || dateField.text!.isEmpty) {
            
            self.present(alertEmpty, animated: true)
        } else {
            
            let requestID = String(Date().timeIntervalSince1970)
            print ("PJ \(requestID)")
            
            let flNumber = flightNumber!.text
            let flDate = dateField!.text
            let email = emailField!.text
            let phone = mobile!.getFormattedPhoneNumber(format: .E164)
            let fName = firstName!.text
            let lName = lastName!.text
            let origin = fromField!.text
            let destination = toField!.text
            
            
            let dataSet : [String : Any] = ["flightNumber" : flNumber!,
                                            "flightDate" : flDate!,
                                            "email" : email!,
                                            "phone" : phone!,
                                            "PNR" : boardingPass["PNR"] as! String,
                                            "firstName" : fName!,
                                            "lastName" : lName!,
                                            "origin" : origin!,
                                            "destination" : destination!,
                                            "created" : Timestamp()
            ]
            
            
            if (isEmailOK && isPhoneValid && isChecked) {
                SVProgressHUD.setDefaultStyle(.dark)
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
                SVProgressHUD.show()
                FirebaseManager.sharedInstance.write2Firestore(collection: "requests", document: requestID, dataSet: dataSet) {
                    self.present(alertSent, animated: true)
                    SVProgressHUD.dismiss()
                }
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "ZWERYFIKUJ DANE"
        
        dateField.delegate = self
        emailField.delegate = self
        mobile.delegate = self
        flightNumber.delegate = self
        
        backgroundView.layer.cornerRadius = 10
        sendButton.layer.cornerRadius = 5
        sendButton.clipsToBounds = false
        sendButton.layer.shadowColor = UIColor.black.cgColor
        sendButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        sendButton.layer.shadowOpacity = 0.7
        sendButton.layer.shadowRadius = 4.0
        sendButton.titleLabel?.textAlignment = NSTextAlignment.center
        
        
        flightNumber.placeholder = "Nr lotu, np. XX 123"
        dateField.placeholder = "Data lotu"
        emailField.placeholder = "Adres e-mail"
        
        //init toolbar
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(doneButtonAction(sender:)))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        //setting toolbar as inputAccessoryView
        mobile.textFieldInputAccessoryView = toolbar
        
        showDatePicker()
        
        if boardingPass == nil {
            print("PJ pusty boarding pass")
        } else {
            print("PJ boarding pass przekazany do manual input: \(String(describing: boardingPass))")
            flightNumber.text = (boardingPass["flightNumber"] as! String)
            firstName.text = (boardingPass["firstName"] as! String)
            lastName.text = (boardingPass["lastName"] as! String)
            fromField.text = (boardingPass["origin"] as! String)
            toField.text = (boardingPass["destination"] as! String)
            
            let dateComponents = NSDateComponents()
            dateComponents.year = 2019
            dateComponents.day = boardingPass!["julianDate"] as! Int
            let calendar = NSCalendar.current
            let date = calendar.date(from: dateComponents as DateComponents)
           
            
            
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "dd/MM/yyyy"
      
             print("PJ data: \(dateFormatterPrint.string(from: date!))")
            dateField.text = dateFormatterPrint.string(from: date!)
        }
        
    }
    
    private func getCustomTextFieldInputAccessoryView(with items: [UIBarButtonItem]) -> UIToolbar {
        let toolbar: UIToolbar = UIToolbar()
        
        toolbar.barStyle = UIBarStyle.default
        toolbar.items = items
        toolbar.sizeToFit()
        
        return toolbar
    }
    
    
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Anuluj", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        dateField.inputAccessoryView = toolbar
        dateField.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dateField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    
    @objc func doneButtonAction(sender: UIBarButtonItem) {
        self.mobile.resignFirstResponder()
        //        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        print("PJ end????")
        //or
        //self.view.endEditing(true)
        return true
    }
    
  

}



extension ScannerInputViewController: FPNTextFieldDelegate {
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code) // Output "France", "+33", "FR"
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        textField.rightViewMode = .always
        //        textField.rightView = UIImageView(image: isValid ? #imageLiteral(resourceName: "success") : #imageLiteral(resourceName: "error"))
        isPhoneValid = isValid
        
//        print(
//            isValid,
//            textField.getFormattedPhoneNumber(format: .E164),
//            textField.getFormattedPhoneNumber(format: .International),
//            textField.getFormattedPhoneNumber(format: .National),
//            textField.getFormattedPhoneNumber(format: .RFC3966),
//            textField.getRawPhoneNumber()
//        )
    }
}

//extension String {
//    func isValidEmail() -> Bool {
//        // here, `try!` will always succeed because the pattern is valid
//        let regex = try! NSRegularExpression(pattern: "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
//            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
//            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
//            "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
//            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
//            "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
//            "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])", options: .caseInsensitive)
//        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
//    }
//}
