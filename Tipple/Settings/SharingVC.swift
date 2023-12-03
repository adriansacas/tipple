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
    var userID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser {
            userID = user.uid
            setSwitchState()
        } else {
            print("No current user.")
        }
    }
    
    func setSwitchState() {
        guard let userID = userID else {
            return
        }
        
        firestoreManager.getUserData(userID: userID) { [weak self] (profileInfo, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
            } else if let profileInfo = profileInfo {
                self?.shareDrinkInfo.isOn = profileInfo.shareDrinkInfo
                self?.shareLocation.isOn = profileInfo.shareLocation
            }
        }
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        guard let userID = userID else {
            return
        }
        
        let updatedData: [String: Any] = [
            "shareDrinkInfo": shareDrinkInfo.isOn,
            "shareLocation": shareLocation.isOn
        ]
        
        firestoreManager.updateUserDocument(userID: userID, updatedData: updatedData)
        navigationController?.popViewController(animated: true)
    }
}
