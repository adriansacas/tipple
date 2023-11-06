//
//  GroupListViewController.swift
//  Tipple
//
//  Created by Claudia Castillo on 11/5/23.
//

import UIKit
import FirebaseAuth

class GroupListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let firestoreManager = FirestoreManager.shared
    
    var userID:String?
    var session:SessionInfo?
    var users:[String: [String: Any]]?
    var keys:[String] = []
    var textCellIdentifier = "TextCell"
    var row:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let userID = Auth.auth().currentUser?.uid {
            self.userID = userID
        } else {
            print("Error fetching user ID from currentUser")
        }
        
        firestoreManager.pullGroupMembers(userID: userID!, sessionID: (session?.getSessionDocID())!) {
            users, error in
            if let error = error {
                print("Error updating symptoms: \(error)")
            } else {
                self.tableView.beginUpdates()
                self.users = users
                for user in users! {
                    self.keys.append(user.key)
                }
                self.tableView.endUpdates()
            }
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
    
        let row = indexPath.row
        
        var user = users![keys[row]]
        
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
