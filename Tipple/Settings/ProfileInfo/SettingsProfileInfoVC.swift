//
//  SettingsProfileInfoViewController.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/12/23.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

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
    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImage.layer.masksToBounds = false
        self.profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        self.profileImage.clipsToBounds = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getCurrentUser()
        tapGesture()
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
                self.getUserProfileData()
            } else {
                // No error and no user. Handled in AuthenticationManager
                print("No user found and no error occurred.")
            }
        }
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
                cell.detailTextLabel?.text = currentUser?.email
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
        guard let currentUser  = currentUser else {
            return
        }
        
        firestoreManager.getUserData(userID: currentUser.uid) { [weak self] (profileInfo, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
            } else if let profileInfo = profileInfo {
                self?.userProfileInfo = profileInfo
                // Reload the table view to update the detailTextLabels
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.setProfileImage()
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
        guard let currentUser = currentUser else {
            return
        }
        
        if let selectedImage = info[.originalImage] as? UIImage {
            uploadImageToFirebaseStorage(image: selectedImage) { [weak self] (url, error) in
                if let url = url {
                    let updatedData: [String: Any] = [
                        "profileImageURL": url.absoluteString
                    ]

                    self?.firestoreManager.updateUserDocument(userID: currentUser.uid, updatedData: updatedData)

                    // Update the profileImage UIImageView with the selected image
                    self?.profileImage.image = selectedImage
                } else {
                    // Handle the error
                    print("Image upload error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }

        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadImageToFirebaseStorage(image: UIImage, completion: @escaping (URL?, Error?) -> Void) {
        guard let currentUser = currentUser else {
            return
        }
        
        // Create a reference to Firebase Storage
        let storage = Storage.storage()
        let storageReference = storage.reference()

        // Create a unique name for the image (e.g., user's UID + a timestamp)
        let imageName = "\(currentUser.uid).jpg"

        // Create a reference to the file in Firebase Storage
        let imageRef = storageReference.child("profile_images/\(imageName)")

        // Convert the image to Data
        if let imageData = image.jpegData(compressionQuality: 0.3) {
            // Upload the image
            _ = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    completion(nil, error)
                } else {
                    // Image uploaded successfully
                    imageRef.downloadURL { (url, error) in
                        if let downloadURL = url {
                            completion(downloadURL, nil)
                        } else {
                            completion(nil, error)
                        }
                    }
                }
            }
        } else {
            // Handle data conversion error
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Image conversion failed"])
            completion(nil, error)
        }
    }
    
    func setProfileImage() {
        guard let imageURLString = userProfileInfo?.profileImageURL,
              let imageURL = URL(string: imageURLString) else {
            return
        }

        // Create a URLSession data task to download the image
        URLSession.shared.dataTask(with: imageURL) { [weak self] (data, response, error) in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                return
            }

            // Ensure that the downloaded data is an image
            if let data = data, let image = UIImage(data: data) {
                // Update the profileImage UIImageView on the main thread
                DispatchQueue.main.async {
                    self?.profileImage.image = image
                }
            }
        }.resume()
    }
}
