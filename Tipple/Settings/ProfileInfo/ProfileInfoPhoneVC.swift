//
//  ProfileInfoPhoneVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/13/23.
//

import UIKit
import FirebaseAuth

class ProfileInfoPhoneVC: UITableViewController, UITextFieldDelegate, ProfileInfoDelegateSettingVC {
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    weak var delegate: ProfileInfoDelegate?
    var userProfileInfo: ProfileInfo?
    let firestoreManager = FirestoreManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneTextField.borderStyle = .none
        phoneTextField.keyboardType = .numberPad
        
        phoneTextField.delegate = self
        
        setInitialPhone()
    }
    
    func setInitialPhone() {
        if let phone = userProfileInfo?.phoneNumber {
            phoneTextField.text = phone
        }
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        guard let userID = Auth.auth().currentUser?.uid,
              let newPhoneNumber = phoneTextField.text else {
            // Handle invalid input or user not authenticated
            return
        }

        if isValidPhoneNumber(newPhoneNumber) {
            let updatedData: [String: Any] = [
                "phoneNumber": newPhoneNumber
            ]

            firestoreManager.updateUserDocument(userID: userID, updatedData: updatedData)

            userProfileInfo?.phoneNumber = newPhoneNumber

            if let updatedProfileInfo = userProfileInfo {
                delegate?.didUpdateProfileInfo(updatedProfileInfo)
            }
            
            navigationController?.popViewController(animated: true)
        } else {
            print("Invalid phone number entered.")
        }
    }
    
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        // Remove hyphens from the phone number
        let cleanedPhoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "")
        
        if let _ = Int(cleanedPhoneNumber) {
            // The cleaned phone number can be converted to an integer
            return true
        } else {
            // The phone number contains non-numeric characters
            return false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Limit the number of characters to 10
        let currentText = textField.text ?? ""
        let newLength = currentText.count + string.count - range.length
        if newLength > 10 {
            return false
        }
        
//        TODO: add hyphens to phone number as the user types
        // Add hyphens to format the phone number
//        if newLength == 4 || newLength == 9 {
//            textField.text?.insert("-", at: textField.text!.index(textField.text!.endIndex, offsetBy: -1))
//        }
        	
        return true
    }
}
