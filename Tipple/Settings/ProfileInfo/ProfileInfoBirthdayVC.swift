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
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentUser()

        if let birthday = userProfileInfo?.birthday {
            datePicker.date = birthday
        }
    }
    
    func getCurrentUser() {
        AuthenticationManager.shared.getCurrentUser(viewController: self) { user, error in
            if let error = error {
                // Errors are handled in AuthenticationManager
                print("Error retrieving user: \(error.localizedDescription)")
            } else if let user = user {
                // Successfully retrieved the currentUser
                self.currentUser = user
                // Do anything that needs the currentUser
            } else {
                // No error and no user. Handled in AuthenticationManager
                print("No user found and no error occurred.")
            }
        }
    }

    @IBAction func saveChanges(_ sender: Any) {
        guard let currentUser = currentUser else {
            // Handle invalid input or user not authenticated
            return
        }

        let birthday = datePicker.date // Get the selected date
        
        let updatedData: [String: Any] = [
            "birthday": birthday
        ]
        
        firestoreManager.updateUserDocument(userID: currentUser.uid, updatedData: updatedData)
        
        userProfileInfo?.birthday = birthday
        
        if let updatedProfileInfo = userProfileInfo {
            delegate?.didUpdateProfileInfo(updatedProfileInfo)
        }
        
        navigationController?.popViewController(animated: true)
    }
}
