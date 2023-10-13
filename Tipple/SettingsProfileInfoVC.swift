//
//  SettingsProfileInfoViewController.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/12/23.
//

import UIKit

class SettingsProfileInfoVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    let textCellIdentifier = "TextCell"
    let tableFields: [String] = ["Name", "Birthday", "Gender", "Height", "Weight", "Phone", "Email"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImage.layer.masksToBounds = false
        self.profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        self.profileImage.clipsToBounds = true
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableFields.count
    }
    
    // UITableViewDataSource method: Configures and returns a table view cell for a specific row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure each cell in the table view.
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = tableFields[row]
//        TODO: Replace with firebase data
        cell.detailTextLabel?.text = "Detail"
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

}
