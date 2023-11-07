//
//  MemberInfoViewController.swift
//  Tipple
//
//  Created by Claudia Castillo on 11/5/23.
//

import UIKit
import FirebaseAuth

class MemberInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameField: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let firestoreManager = FirestoreManager.shared
    let textCellIdentifier = "TextCell"
    
    var keys:[String] = []
    var user:[String:Any]?
    var delegate:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.profilePic.layer.masksToBounds = false
        self.profilePic.layer.cornerRadius = profilePic.frame.size.height / 2
        self.profilePic.clipsToBounds = true

        for key in user!.keys {
            if key == "Profile Pic" {
                setProfileImage(url: user![key] as? String)
            } else if key != "name" || key != "SESSIONVALUES" {
                keys.append(key)
            }
        }
        nameField.text = user!["name"] as? String
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath) as! PersonCell
    
        let row = indexPath.row
        
        let key = String(keys[row])
        
        cell.keyField.text = key
        cell.valueField.text = user![key] as? String
        
        return cell
    }
    
    func setProfileImage(url:String?) {
        guard let imageURLString = url,
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
                    self?.profilePic.image = image
                }
            }
        }.resume()
    }

}

class PersonCell: UITableViewCell {
    @IBOutlet weak var keyField: UILabel!
    @IBOutlet weak var valueField: UILabel!
    
}
