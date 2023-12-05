//
//  ManageGroupSessionViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/26/23.
//

import UIKit
import CoreLocation
import Foundation

//protocol to update session name
protocol EditSession {
    func updateSessionInfo(sessionFields: [String : Any])
    func endSessionForUser(markForDeletion: Bool)
}

class ManageGroupSessionVC: UIViewController, CLLocationManagerDelegate, EditSession {
    
    @IBOutlet weak var sessionNameTextLabel: UILabel!
    @IBOutlet weak var sessionEndDateTimeLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var stopSessionButton: UIButton!
    let firestoreManager = FirestoreManager.shared
    let locationManager = FirestoreManager.location

    var groupQRCode: UIImage?
    var sessionID: String?
    var userID: String?
    var sessionName: String = ""
    var endDate: Date?
    var isManager: Bool = true
    var pollTimer: Timer?
    var prevBAC: [String: Double] = [:]
    var isDD: Bool?
    var isLocationEnabled: Bool = false
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
        
        // Setting Up Location Manager
        locationManager.delegate = self
        
        pollTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(pollSessionInfo), userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Redundant first setting
        setLabelFields(nameField: self.sessionName, dateField: self.endDate!)
        
        self.groupQRCode = generateQRCode(from: self.sessionID!)

        
        // Start updating location
        if isLocationEnabled && 
            (locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse){
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop the timer when the view disappears
        pollTimer?.invalidate()
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        print("Generating QR Code: \(string)")
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                print("\tSuccess on QR Generation!!")
                return UIImage(ciImage: output)
            }
        }
        return nil
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
        locationManager.stopUpdatingLocation()
        
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
                self.checkDrunkFriends(users: users)
            }
        }
    }
    
    func checkDrunkFriends(users: [String: [String: Any]]) {
        
        for user in users.keys {
            if(user == "SESSIONVALUES") {
                continue
            } else if self.prevBAC[user] == nil { // set to 0.0 if we don't have a prev BAC
                self.prevBAC[user] = 0.0
            }
            
            let curr =  Double((users[user]!["BAC"] as? String)!)
            if(curr != nil) {
                let prev = self.prevBAC[user]
                // display alert if BAC has increment and is higher than 0.12
                if prev! < curr! && curr! > 0.12 {
                    let name = users[user]!["name"] as? String
                    AlertUtils.showAlert(title: "Check on \(name ?? "your friends")", message: "\(name ?? "someone")'s BAC is at \(users[user]!["BAC"] as? String ?? "a dangerous level")", viewController: self)
                }
                // update BAC
                self.prevBAC[user] = curr
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Handle changes if location permissions
        guard isLocationEnabled, status != .authorizedAlways && status != .authorizedWhenInUse else {
            // Status changed to allow location updates
            locationManager.startUpdatingLocation()
            return
        }
        
        AlertUtils.showAlert(title: "Location Cannot Be Updated",
                             message: "Please enable location permissions in iOS Settings.",
                             viewController: self)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isLocationEnabled else {
            return
        }

        print("Method Called To Update Location")

        if let location = locations.last {
            // Perform UI-related tasks on the main thread
            DispatchQueue.main.async {
                // Handle location update --> Call firebase manager to update the location
                self.firestoreManager.updateLastLocation(sessionID: self.sessionID!,
                                                    userID: self.userID!,
                                                    coordinate: location.coordinate) { error in
                    if error != nil {
                        print("Issue updating location in firebase")
                    }
                }
            }
        }
    }


    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle failure to get a user’s location
        guard isLocationEnabled else {
            return
        }
        print("Had an issue retrieving location. Will not do anything for now :/")
    }

    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == inviteCodeSegue, let destination = segue.destination as? InviteCodeVC {
            destination.groupQRCode = self.groupQRCode
            destination.sessionName = self.sessionName
            destination.sessionID = self.sessionID!
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
