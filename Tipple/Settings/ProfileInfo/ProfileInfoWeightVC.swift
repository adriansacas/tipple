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
        
        weightTextField.borderStyle = .none
        weightTextField.keyboardType = .numberPad
        
        setInitialWeight()
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
