//
//  GroupListViewController.swift
//  Tipple
//
//  Created by Claudia Castillo on 11/5/23.
//

import UIKit
import FirebaseAuth

class GroupListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let firestoreManager = FirestoreManager.shared
    
    var userID:String?
    var sessionID:String?
    var users:[String: [String: Any]]?
    var keys:[String] = []
    var textCellIdentifier = "TextCell"
    var row:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        // pull users from firebase
        firestoreManager.pollGroupSession(userID: userID!, sessionID: sessionID!) {
            users, error in
            if let error = error {
                print("Error updating symptoms: \(error)")
            } else {
//                for key in users!.keys {
//                    if key != "SESSIONVALUES" {
//                        self.users![key] = users![key]
//                    }
//                }
                self.users = users
                self.keys.removeAll()
                for user in users! {
                    if user.key != "SESSIONVALUES" {
                        self.keys.append(user.key)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }

    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = keys.count
        self.tableView.isHidden = count == 0 // Hide tableView if no polls
        self.initialLabel.isHidden = count != 0 // Show noPollsLabel if no polls
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
    
        let row = indexPath.row
        let user = users![keys[row]]
        
        cell.textLabel?.text = user!["name"] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.row = indexPath.row
        self.performSegue(withIdentifier: "UserInfoSegue", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserInfoSegue",
           let nextVC = segue.destination as? MemberInfoViewController
        {
            nextVC.delegate = self
            nextVC.user = users![keys[row!]]
        }
    }

}
