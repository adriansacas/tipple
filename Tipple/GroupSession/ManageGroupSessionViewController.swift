//
//  ManageGroupSessionViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/26/23.
//

import UIKit
import Foundation

//protocol to update session name
protocol EditSession {
    func updateSessionInfo(sessionFields: [String : Any])
}

class ManageGroupSessionVC: UIViewController, EditSession {
    
    @IBOutlet weak var sessionNameTextLabel: UILabel!
    @IBOutlet weak var sessionEndDateTimeLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var stopSessionButton: UIButton!
    let firestoreManager = FirestoreManager.shared

    var groupQRCode: UIImage?
    var sessionID: String?
    var userID: String?
    var sessionName: String = ""
    var endDate: Date = Date()
    var isManager: Bool = true
    var pollTimer: Timer?

    let inviteCodeSegue = "inviteCodeSegue"
    let sessionSettingSegue = "sessionSettingSegue"
    let activeSessionSegue = "manageToActiveSegue"
    let groupListSegue = "groupListSegue"
    let pollsSegue = "PollsSegueIdentifier"
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print(self.isManager)
        print("About to load manage page: \(self.userID ?? "noUserID")")
        if !isManager {
            settingsButton.isHidden = true
            settingsButton.isEnabled = false
            stopSessionButton.setTitle("Leave Session", for: .normal)
        }
        pollTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(pollSessionInfo), userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Redundant first setting
        setLabelFields(nameField: self.sessionName, dateField: self.endDate)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop the timer when the view disappears
        pollTimer?.invalidate()
    }
    
    func setLabelFields(nameField: String, dateField: Date) {
        if nameField != self.sessionNameTextLabel.text {
            self.sessionNameTextLabel.text = nameField
        }

        // Display current session name and end date/time
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let formattedDate = dateFormatter.string(from: dateField)
        
        if formattedDate != self.sessionEndDateTimeLabel.text {
            self.sessionEndDateTimeLabel.text = formattedDate
        }
        
        self.sessionName = nameField
        self.endDate = dateField
    }
    
    func updateSessionInfo(sessionFields: [String : Any]){
        if let sessionName = sessionFields["sessionName"] as? String,
           let endTime = sessionFields["endTime"] as? Date{
               self.setLabelFields(nameField: sessionName, dateField: endTime)
        }
        
        firestoreManager.updateGroupSession(userID: self.userID!, sessionID: self.sessionID!, fields: sessionFields) { error in
            if let error = error {
                print("Error adding session: \(error)")
            } else {
                print("Successfully updated the session fields")
            }
        }
    }
    
    @IBAction func stopSessionButtonPressed(_ sender: Any) {
        
        let stopAlertController = UIAlertController(
            title: isManager ? "Are you sure you want to end?" : "Are you sure you want to leave?",
            message:
                isManager ? "It will end the session for all members." : "You will not receive new updates from this session.",
            preferredStyle: .alert
        )
        
        stopAlertController.addAction(UIAlertAction(
            title: "Cancel",
            style: .default)
        )
        
        stopAlertController.addAction(UIAlertAction(
            title: isManager ? "End" : "Leave",
            style: .destructive,
            handler: {
                (action) in
                
                //TODO: assumes the user stayed logged in, find better solution
                //self.performSegue(withIdentifier: "editSessionToHomeSegue", sender: nil)
            })
        )
        
        present(stopAlertController, animated: true)
    }
    
    // Add @objc annotation to make the function accessible to Timer
    @objc func pollSessionInfo() {
        firestoreManager.pollGroupSession(userID: userID!, sessionID: sessionID!) {
            users, error in
            if let error = error {
                print("Error updating symptoms: \(error)")
            } else if let users = users,
                      let sessionValues = users["SESSIONVALUES"] {
                self.setLabelFields(nameField: sessionValues["sessionName"] as! String, dateField: sessionValues["endTime"] as! Date)
            }
        }
    }
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == inviteCodeSegue, let destination = segue.destination as? InviteCodeVC {
            destination.groupQRCode = self.groupQRCode
            destination.sessionName = self.sessionName
            destination.endDate = self.endDate
            
        } else if segue.identifier == sessionSettingSegue, let destination = segue.destination as? EditGroupSessionVC {
            destination.delegate = self
            destination.sessionName = self.sessionName
            destination.endDate = self.endDate
        } else if segue.identifier == activeSessionSegue, let destination = segue.destination as? ShowActiveVC {
            destination.userID = self.userID
            destination.sessionID = self.sessionID
        }  else if segue.identifier == groupListSegue, let destination = segue.destination as? GroupListViewController {
            destination.sessionID = self.sessionID
            destination.userID = self.userID
        } else if segue.identifier == pollsSegue {
            if let navController = segue.destination as? UINavigationController,
               let destination = navController.topViewController as? PollsVC {
                destination.sessionID = self.sessionID
            }
        }
    }

}
