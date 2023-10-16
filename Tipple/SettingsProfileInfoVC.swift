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

protocol ProfileInfoDelegateSettingVC: UIViewController {
    var userProfileInfo: ProfileInfo? { get set }
    var delegate: ProfileInfoDelegate? { get set }
}

class SettingsProfileInfoVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ProfileInfoDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    let textCellIdentifier = "TextCell"
    let tableFields: [String] = ["Name", "Birthday", "Gender", "Height", "Weight", "Phone", "Email"]
    let firestoreManager = FirestoreManager.shared
    var userProfileInfo: ProfileInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImage.layer.masksToBounds = false
        self.profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        self.profileImage.clipsToBounds = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getUserProfileData()
        
        tapGesture()
    }
    
    func didUpdateProfileInfo(_ updatedInfo: ProfileInfo) {
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
        guard let destination = segue.destination as? ProfileInfoDelegateSettingVC else {
            return
        }

        destination.userProfileInfo = userProfileInfo
        destination.delegate = self
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
    
    func tapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tap)
    }
    
    @objc func profileImageTapped() {
//        let imagePicker = UIImagePickerController()
//        imagePicker.sourceType = .photoLibrary
//        self.present(imagePicker, animated: true, completion: nil)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        let alertController = UIAlertController(title: "Change Profile Picture", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                // Handle when the camera is not available
            }
        }))

        alertController.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            // Update the profileImage UIImageView with the selected image
            profileImage.image = image

            // Save the image to UserDefaults or another storage mechanism if needed
            // Note: For a production app, consider using a dedicated image storage service like Firebase Storage.
        }

        picker.dismiss(animated: true, completion: nil)
    }
}
