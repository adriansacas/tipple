//
//  QuestionnaireVC.swift
//  Tipple
//
//  Created by Andrew White on 10/15/23.
//

import UIKit
import FirebaseAuth

class QuestionnaireVC: UIViewController {
    

    @IBOutlet weak var eatenToggle: UISwitch!
    @IBOutlet weak var shareSession: UISwitch!
    @IBOutlet weak var partyLocation: UISearchBar!
    @IBOutlet weak var endLocation: UISearchBar!
    
    var userID: String?
    var sessionID: String?
    var userProfileInfo: ProfileInfo?
    var currentSession: SessionInfo?
    
    let firestoreManager = FirestoreManager.shared
    let qToActiveSegue = "questionToActiveSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getUserID()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Just ensuring that the search fields are getting reset at the end of a view
        partyLocation.text = nil
        endLocation.text = nil
    }
    
    
    func getUserProfileData(user: String) {
        firestoreManager.getUserData(userID: user) { [weak self] (profileInfo, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
            } else if let profileInfo = profileInfo {
                self?.userProfileInfo = profileInfo
            }
        }
        
    }
    
    func getUserID() {
        if let userID = Auth.auth().currentUser?.uid {
            self.userID = userID
            getUserProfileData(user: userID)
        } else {
            print("Error fetching user ID from currentUser")
        }
    }
    
    @IBAction func startSessionButton(_ sender: Any) {
        let session = SessionInfo(
            startTime: Date.now,
            sessionType: "Individual",
            drinksInSession: [],
            startLocation: partyLocation.text ?? "",
            endLocation: endLocation.text ?? "",
            ateBefore: eatenToggle.isOn,
            sessionName: "My Session",
            shareSession: shareSession.isOn,
            membersList: []
        )
        
        self.currentSession = session
        self.performSegue(withIdentifier: qToActiveSegue, sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == qToActiveSegue,
           let destination = segue.destination as? ShowActiveVC {
            destination.userID = self.userID
            destination.userProfileInfo = self.userProfileInfo
            destination.currentSession = self.currentSession
        }
    }
    
}
