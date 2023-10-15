//
//  ProfileInfoBirthdayVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/13/23.
//

import UIKit
import FirebaseAuth

class ProfileInfoBirthdayVC: UIViewController, ProfileInfoDelegateSettingVC {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    weak var delegate: ProfileInfoDelegate?
    var userProfileInfo: ProfileInfo?
    let firestoreManager = FirestoreManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let birthday = userProfileInfo?.birthday {
            datePicker.date = birthday
        }
    }

    @IBAction func saveChanges(_ sender: Any) {
        guard let userID = Auth.auth().currentUser?.uid else {
            // Handle invalid input or user not authenticated
            return
        }

        let birthday = datePicker.date // Get the selected date
        
        let updatedData: [String: Any] = [
            "birthday": birthday
        ]
        
        firestoreManager.updateUserDocument(userID: userID, updatedData: updatedData)
        
        userProfileInfo?.birthday = birthday
        
        if let updatedProfileInfo = userProfileInfo {
            delegate?.didUpdateProfileInfo(updatedProfileInfo)
        }
        
        navigationController?.popViewController(animated: true)
    }
}
