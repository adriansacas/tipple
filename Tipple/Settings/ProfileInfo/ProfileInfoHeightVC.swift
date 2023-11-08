//
//  ProfileInfoHeightVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/13/23.
//

import UIKit
import FirebaseAuth

class ProfileInfoHeightVC: UITableViewController, ProfileInfoDelegateSettingVC {
    
    @IBOutlet weak var feetTextField: UITextField!
    @IBOutlet weak var inchesTextField: UITextField!
    
    weak var delegate: ProfileInfoDelegate?
    var userProfileInfo: ProfileInfo?
    let firestoreManager = FirestoreManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissKeyboardGesture()
        
        feetTextField.borderStyle = .none
        inchesTextField.borderStyle  = .none
        
        feetTextField.keyboardType = .numberPad
        inchesTextField.keyboardType = .numberPad
        
        setInitialHeight()
    }
    
    // Add a gesture recognizer to dismiss the keyboard when the user
    // taps outside of any text field.
    func dismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    func setInitialHeight() {
        if let heightFeet = userProfileInfo?.heightFeet {
            feetTextField.text = String(heightFeet)
        }
        
        if let heightInches = userProfileInfo?.heightInches {
            inchesTextField.text = String(heightInches)
        }
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        guard let userID = Auth.auth().currentUser?.uid,
              let feetText = feetTextField.text,
              let inchesText = inchesTextField.text,
              let feet = Int(feetText),
              let inches = Int(inchesText) else {
            // Handle invalid input or user not authenticated
            return
        }

        let updatedData: [String: Any] = [
            "heightFeet": feet,
            "heightInches": inches
        ]
        
        firestoreManager.updateUserDocument(userID: userID, updatedData: updatedData)
        
        userProfileInfo?.heightFeet = feet
        userProfileInfo?.heightInches = inches
        
        if let updatedProfileInfo = userProfileInfo {
            delegate?.didUpdateProfileInfo(updatedProfileInfo)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
}
