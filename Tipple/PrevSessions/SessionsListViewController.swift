//
//  SessionsListViewController.swift
//  Tipple
//
//  Created by Claudia Castillo on 10/16/23.
//

import UIKit
import FirebaseAuth

class SessionsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var userID:String?
    var sessions:[SessionInfo]?
    var sessionRow:Int?
    let firestoreManager = FirestoreManager.shared
    
    @IBOutlet weak var tableView: UITableView!
    
    let textCellIdentifier = "TextCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.sessions = []

        // get sessions for user from firebase
        if let userID = Auth.auth().currentUser?.uid {
            self.userID = userID
        } else {
            print("Error fetching user ID from currentUser")
        }
        
        firestoreManager.getAllSessions(userID: userID!) {
            list, error in
            if let error = error {
                print("Error retrieving session: \(error)")
            } else {
                self.tableView.beginUpdates()
                var count = 0
                for sesh in list! {
                    self.sessions!.append(sesh)
                    let indexPath = IndexPath(row: count, section: 0)
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                    count += 1
                }
                self.tableView.endUpdates()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
    
        let row = indexPath.row
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YY"
        let date = dateFormatter.string(from: sessions![row].getStartTime())
        
        cell.textLabel?.text = "\(date)  \(sessions![row].getName())"

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sessionRow = indexPath.row
        
        self.performSegue(withIdentifier: "DayViewSegueIdentifier", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DayViewSegueIdentifier",
           let nextVC = segue.destination as? DayViewController
        {
            nextVC.delegate = self
            nextVC.session = self.sessions![self.sessionRow!]
            nextVC.sessionID = self.self.sessions![self.sessionRow!].getSessionDocID()
            nextVC.userID = self.userID!
        }
    }

}
