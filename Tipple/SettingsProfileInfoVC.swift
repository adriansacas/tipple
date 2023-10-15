//
//  SettingsProfileInfoViewController.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/12/23.
//

import UIKit
import FirebaseAuth

protocol ProfileInfoDelegate: AnyObject {
    func didUpdateProfileInfo(_ updatedInfo: ProfileInfo)
}

class SettingsProfileInfoVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ProfileInfoDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    let textCellIdentifier = "TextCell"
    let tableFields: [String] = ["Name", "Birthday", "Gender", "Height", "Weight", "Phone", "Email"]
    let firestoreManager = FirestoreManager.shared
//    var userProfileData: [String: Any] = [:]
    var userProfileInfo: ProfileInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImage.layer.masksToBounds = false
        self.profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        self.profileImage.clipsToBounds = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getUserProfileData()
        
        // TESTING: Create a user document
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        if let birthDate = dateFormatter.date(from: "2024-10-14"), let userID = Auth.auth().currentUser?.uid, let email = Auth.auth().currentUser?.email {
//            FirestoreManager.shared.createUserDocument(
//                userID: userID,
//                firstName: "John",
//                lastName: "Doe",
//                phoneNumber: "1234567890",
//                birthDay: birthDate,
//                gender: "Man",
//                heightFeet: 6,
//                heightInches: 2,
//                weight: 180,
//                email: email
//            )
//        } else {
//            print("Invalid date format or invalid userid")
//        }
    }
    
    func didUpdateProfileInfo(_ updatedInfo: ProfileInfo) {
        print("delegate")
        userProfileInfo = updatedInfo
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableFields.count
    }
    
    // UITableViewDataSource method: Configures and returns a table view cell for a specific row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure each cell in the table view.
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        let row = indexPath.row
        let fieldName = tableFields[row]
        cell.textLabel?.text = fieldName
        
        if let userProfileInfo = userProfileInfo {
            switch tableFields[row] {
            case "Name":
                cell.detailTextLabel?.text = userProfileInfo.getName()
            case "Birthday":
                cell.detailTextLabel?.text = userProfileInfo.getBirthDate()
            case "Gender":
                cell.detailTextLabel?.text = userProfileInfo.gender
            case "Height":
                cell.detailTextLabel?.text = userProfileInfo.getHeight()
            case "Weight":
                cell.detailTextLabel?.text = userProfileInfo.getWeight()
            case "Phone":
                cell.detailTextLabel?.text = userProfileInfo.getPhoneNumber()
            case "Email":
                cell.detailTextLabel?.text = Auth.auth().currentUser?.email
            default:
                cell.detailTextLabel?.text = "N/A"
            }
        } else {
            cell.detailTextLabel?.text = "N/A"
        }
        
        cell.detailTextLabel?.textColor = UIColor.gray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableFields[indexPath.row]

        switch selectedCell {
        case "Name":
            performSegue(withIdentifier: "NameSegueIdentifier", sender: self)
        case "Birthday":
            performSegue(withIdentifier: "BirthdaySegueIdentifier", sender: self)
        case "Gender":
            performSegue(withIdentifier: "GenderSegueIdentifier", sender: self)
        case "Height":
            performSegue(withIdentifier: "HeightSegueIdentifier", sender: self)
        case "Weight":
            performSegue(withIdentifier: "WeightSegueIdentifier", sender: self)
        case "Phone":
            performSegue(withIdentifier: "PhoneSegueIdentifier", sender: self)
        case "Email":
            performSegue(withIdentifier: "EmailSegueIdentifier", sender: self)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NameSegueIdentifier",
           let destination = segue.destination as? ProfileInfoNameVC {
            destination.userProfileInfo = userProfileInfo
            destination.delegate = self
        }
    }
    
    func getUserProfileData() {
        if let userID = Auth.auth().currentUser?.uid {
            firestoreManager.getUserData(userID: userID) { [weak self] (profileInfo, error) in
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                } else if let profileInfo = profileInfo {
                    self?.userProfileInfo = profileInfo
                    // Reload the table view to update the detailTextLabels
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
//    func fetchUserProfileData() {
//        if let userID = Auth.auth().currentUser?.uid {
//            firestoreManager.getUserData(userID: userID) { result in
//                switch result {
//                case .success(let userData):
//                    self.userProfileData = userData
//                    // Reload the table view to update the detailTextLabels
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
//                    print(self.userProfileData)
//                case .failure(let error):
//                    print("Error fetching user data: \(error.localizedDescription)")
//                }
//            }
//        }
//    }

}
