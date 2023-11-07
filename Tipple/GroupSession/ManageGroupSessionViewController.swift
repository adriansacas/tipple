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
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Redundant first setting
        setLabelFields(nameField: self.sessionName, dateField: self.endDate)
    }
    
    
    func setLabelFields(nameField: String, dateField: Date) {
        self.sessionNameTextLabel.text = sessionName

        // Display current session name and end date/time
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let formattedDate = dateFormatter.string(from: dateField)
        self.sessionEndDateTimeLabel.text = formattedDate
        
        self.sessionName = nameField
        self.endDate = dateField
    }
    
    func updateSessionInfo(sessionFields: [String : Any]){
        firestoreManager.updateGroupSession(userID: self.userID!, sessionID: self.sessionID!, fields: sessionFields) { error in
            if let error = error {
                print("Error adding session: \(error)")
            } else {
                if let sessionName = sessionFields["sessionName"] as? String,
                   let endTime = sessionFields["endTime"] as? Date{
                       self.setLabelFields(nameField: sessionName, dateField: endTime)
                }
            
                print("Successfully updated the session fields")
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
