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
    func endSessionForUser(markForDeletion: Bool)
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
    var endDate: Date?
    var isManager: Bool = true
    var pollTimer: Timer?
    var prevBAC: [String: Double]?
    var isDD: Bool?

    var lastUpdate: [String: [String: Any]]?
    
    let inviteCodeSegue = "inviteCodeSegue"
    let sessionSettingSegue = "sessionSettingSegue"
    let activeSessionSegue = "manageToActiveSegue"
    let groupListSegue = "groupListSegue"
    let pollsSegue = "PollsSegueIdentifier"
    let manageHomeSegue = "manageToHomeScreen"
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("About to load manage page: \(self.userID ?? "noUserID")")
        if !isManager {
            settingsButton.isHidden = true
            settingsButton.isEnabled = false
        } else {
            stopSessionButton.setTitle("End Session", for: .normal)
        }
        pollTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(pollSessionInfo), userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Redundant first setting
        setLabelFields(nameField: self.sessionName, dateField: self.endDate!)
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
        
        if dateField <= Date() {
            let stopAlertController = UIAlertController(
                                                title: "Session Finished",
                                                message: "Session has ended or no longer exists.",
                                                preferredStyle: .alert
            )
            
            let action = UIAlertAction(
                title: "OK",
                style: .destructive,
                handler: {
                    (action) in
                    self.performSegue(withIdentifier: self.manageHomeSegue, sender: nil)
                })
            
            action.setValue(UIColor.okay, forKey:"titleTextColor")
            
            stopAlertController.addAction(action)
            
            self.present(stopAlertController, animated: true)
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
        firestoreManager.updateGroupSession(userID: self.userID!, sessionID: self.sessionID!, fields: sessionFields) { error in
            if let error = error {
                print("Error adding session: \(error)")
            } else {
                print("Successfully updated the session fields")
                if let sessionName = sessionFields["sessionName"] as? String,
                   let endTime = sessionFields["endTime"] as? Date{
                       self.setLabelFields(nameField: sessionName, dateField: endTime)
                }
            }
        }
    }
    
    func endSessionForUser(markForDeletion: Bool = false) {
        pollTimer?.invalidate()
        // handle firebase marking of end session
        firestoreManager.endSessionForUser(userID: self.userID!,
                                           sessionID: self.sessionID!,
                                           markForDeletion: markForDeletion) { error in
            if let error = error {
                print("Error ending session: \(error)")
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
        
        
        let action = UIAlertAction(
            title: "Cancel",
            style: .default)
        
        action.setValue(UIColor.okay, forKey:"titleTextColor")
        
        stopAlertController.addAction(action)
        
        stopAlertController.addAction(UIAlertAction(
            title: isManager ? "End" : "Leave",
            style: .destructive,
            handler: {
                (action) in
                self.performSegue(withIdentifier: self.manageHomeSegue, sender: nil)
            })
        )
        
        present(stopAlertController, animated: true)
    }
    
    @objc func pollSessionInfo() {
        firestoreManager.pollGroupSession(userID: userID!, sessionID: sessionID!) { users, error in
            if let error = error {
                print("Error updating symptoms: \(error)")
            } else if let users = users, let sessionValues = users["SESSIONVALUES"] {
                self.lastUpdate = users
                if let sessionName = sessionValues["sessionName"] as? String,
                   let endTime = sessionValues["endTime"] as? Date {
                    self.setLabelFields(nameField: sessionName, dateField: endTime)
                }
                
                // BAC needs testing
                /*
                for user in users {
                    if let curr = user.value["BAC"] as? Double {
                        if let prev = self.prevBAC![user.key] {
                            if prev < curr && curr > 0.12 {
                                let name = user.value["Name"] as? String
                                AlertUtils.showAlert(title: "Check on \(name ?? "your friends")", message: "\(name ?? "someone")'s BAC is at \(curr)", viewController: self)
                            }
                        } else if curr > 0.12 { // if no prev BAC existed
                            let name = user.value["Name"] as? String
                            AlertUtils.showAlert(title: "Check on \(name ?? "your friends")", message: "\(name ?? "someone")'s BAC is at \(curr)", viewController: self)
                        }
                        //set prev to current whether prev existed or not
                        self.prevBAC![user.key]  = curr
                    }
                }
                */
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
            destination.endDate = self.endDate!
            
        } else if segue.identifier == sessionSettingSegue, let destination = segue.destination as? EditGroupSessionVC {
            destination.delegate = self
            destination.sessionName = self.sessionName
            destination.endDate = self.endDate!
        } else if segue.identifier == activeSessionSegue, let destination = segue.destination as? ShowActiveVC {
            destination.userID = self.userID
            destination.sessionID = self.sessionID
            destination.isDD = self.isDD
        }  else if segue.identifier == groupListSegue, let destination = segue.destination as? GroupListViewController {
            destination.users = self.lastUpdate
            destination.sessionID = self.sessionID
            destination.userID = self.userID
        } else if segue.identifier == pollsSegue {
            if let navController = segue.destination as? UINavigationController,
               let destination = navController.topViewController as? PollsVC {
                destination.sessionID = self.sessionID
            }
        } else if segue.identifier == manageHomeSegue, let destination = segue.destination as? HomeViewController{
            
            destination.saveOnKeychain = false
            destination.saveEmail = ""
            destination.savePassword = ""
            
            endSessionForUser()
        }
    }

}
