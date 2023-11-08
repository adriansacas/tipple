//
//  ProfileInfoWeightVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/13/23.
//

import UIKit
import FirebaseAuth

class ProfileInfoWeightVC: UITableViewController, ProfileInfoDelegateSettingVC {
    
    @IBOutlet weak var weightTextField: UITextField!
    
    weak var delegate: ProfileInfoDelegate?
    var userProfileInfo: ProfileInfo?
    let firestoreManager = FirestoreManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissKeyboardGesture()
        
        weightTextField.borderStyle = .none
        weightTextField.keyboardType = .numberPad
        
        setInitialWeight()
    }
    
    // Add a gesture recognizer to dismiss the keyboard when the user
    // taps outside of any text field.
    func dismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    func setInitialWeight() {
        if let weight = userProfileInfo?.weight {
            weightTextField.text = String(weight)
        }
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        guard let userID = Auth.auth().currentUser?.uid,
              let weightText = weightTextField.text,
              let weight = Int(weightText) else {
            // Handle invalid input or user not authenticated
            return
        }

        let updatedData: [String: Any] = [
            "weight": weight
        ]

        firestoreManager.updateUserDocument(userID: userID, updatedData: updatedData)

        userProfileInfo?.weight = weight

        if let updatedProfileInfo = userProfileInfo {
            delegate?.didUpdateProfileInfo(updatedProfileInfo)
        }

        navigationController?.popViewController(animated: true)
    }
    
}
