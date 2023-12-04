//
//  SharingVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 12/3/23.
//

import UIKit
import FirebaseAuth

class SharingVC: UITableViewController {
    
    @IBOutlet weak var shareDrinkInfo: UISwitch!
    @IBOutlet weak var shareLocation: UISwitch!
    
    let firestoreManager = FirestoreManager.shared
    let authManager = AuthenticationManager.shared
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentUser()
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
                self.setSwitchState()
            } else {
                // No error and no user. Handled in AuthenticationManager
                print("No user found and no error occurred.")
            }
        }
    }
    
    func setSwitchState() {
        guard let currentUser = currentUser else {
            return
        }
        
        firestoreManager.getUserData(userID: currentUser.uid) { [weak self] (profileInfo, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
            } else if let profileInfo = profileInfo {
                self?.shareDrinkInfo.isOn = profileInfo.shareDrinkInfo
                self?.shareLocation.isOn = profileInfo.shareLocation
            }
        }
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        guard let currentUser = currentUser else {
            return
        }
        
        let updatedData: [String: Any] = [
            "shareDrinkInfo": shareDrinkInfo.isOn,
            "shareLocation": shareLocation.isOn
        ]
        
        firestoreManager.updateUserDocument(userID: currentUser.uid, updatedData: updatedData)
        navigationController?.popViewController(animated: true)
    }
}
