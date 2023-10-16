//
//  ProfileInfoGenderVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/12/23.
//

import UIKit
import FirebaseAuth

class ProfileInfoGenderVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ProfileInfoDelegateSettingVC {
    
    @IBOutlet var tableView: UITableView!
    let textCellIdentifier = "TextCell"
    let tableFields: [String] = ["Man", "Woman", "Non-binary"]
    var selectedIndexPath: IndexPath?
    
    weak var delegate: ProfileInfoDelegate?
    let firestoreManager = FirestoreManager.shared
    var userProfileInfo: ProfileInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        initialSelectedIndexPath()
    }
    
    func initialSelectedIndexPath() {
        if let gender = userProfileInfo?.gender, let genderIndex = tableFields.firstIndex(of: gender) {
            selectedIndexPath = IndexPath(row: genderIndex, section: 0)
        } else {
            print("Error retrieving gender.")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = tableFields[row]
        
        // Checkmark setup
        if selectedIndexPath == indexPath {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the previously selected cell
        if let selectedIndexPath = selectedIndexPath {
            tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .none
        }
        
        // Update the selectedIndexPath
        selectedIndexPath = indexPath
        
        // Set the checkmark for the newly selected cell
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }

    @IBAction func saveChanges(_ sender: Any) {
        guard let selectedIndexPath = selectedIndexPath,
              let userID = Auth.auth().currentUser?.uid else {
            // Handle invalid input or user not authenticated
            return
        }
        
        let gender = tableFields[selectedIndexPath.row]
        
        let updatedData: [String: Any] = [
            "gender": gender
        ]
        
        firestoreManager.updateUserDocument(userID: userID, updatedData: updatedData)
        
        userProfileInfo?.gender = gender
        if let updatedProfileInfo = userProfileInfo {
            delegate?.didUpdateProfileInfo(updatedProfileInfo)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
}