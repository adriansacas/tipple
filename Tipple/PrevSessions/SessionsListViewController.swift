//
//  SessionsListViewController.swift
//  Tipple
//
//  Created by Claudia Castillo on 10/16/23.
//

import UIKit
import FirebaseAuth

protocol update {
    func updateSessions()
}

class SessionsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, update {
    
    var userID:String?
    var sessions:[SessionInfo]?
    var sessionRow:Int?
    let firestoreManager = FirestoreManager.shared
    
    @IBOutlet weak var initialLabel: UILabel!
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
                if list!.isEmpty {
                    self.initialLabel.text = "No previously logged activity"
                }
                self.tableView.beginUpdates()
                var count = 0
                for sesh in list! {
                    self.sessions!.append(sesh)
                    let indexPath = IndexPath(row: count, section: 0)
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                    count += 1
                }
                self.sessions = self.sessions!.sorted(by: { $0.startTime.compare($1.startTime) == .orderedDescending })
                self.tableView.endUpdates()
                
                // Update the polls array and refresh the table view
//                self.sessions! = list!.sorted(by: { $0.startTime.compare($1.startTime) == .orderedDescending })
//                self.tableView.reloadData()
//                DispatchQueue.main.async {
//                    self?.tableView.reloadData()
//                }
                
            }
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = sessions!.count
//        self.tableView.isHidden = count == 0 // Hide tableView if no polls
//        self.initialLabel.isHidden = count != 0 // Show noPollsLabel if no polls
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
    
        let row = indexPath.row
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YY"
        let date = dateFormatter.string(from: sessions![row].getStartTime())
        
        cell.textLabel?.text = "\(date)  \(sessions![row].getName())"
    
        updateVisibility()

        return cell
    }
    
    private func updateVisibility() {
       DispatchQueue.main.async {
           let hasSessions = !self.sessions!.isEmpty
           self.tableView.isHidden = !hasSessions
           self.initialLabel.isHidden = hasSessions
       }
   }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sessionRow = indexPath.row
        
        self.performSegue(withIdentifier: "DayViewSegueIdentifier", sender: self)
        
    }
    
    func updateSessions() {
        firestoreManager.getAllSessions(userID: userID!) {
            list, error in
            if let error = error {
                print("Error retrieving session: \(error)")
            } else {
                self.sessions![self.sessionRow!] = list![self.sessionRow!]
                self.tableView.reloadData()
            }
        }
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
