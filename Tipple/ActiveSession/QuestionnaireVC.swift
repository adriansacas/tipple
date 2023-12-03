//
//  QuestionnaireVC.swift
//  Tipple
//
//  Created by Andrew White on 10/15/23.
//

import UIKit
import FirebaseAuth
import GooglePlaces
import CoreLocation


class QuestionnaireVC: UIViewController, UITextFieldDelegate, GMSAutocompleteViewControllerDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var eatenToggle: UISwitch!
    @IBOutlet weak var isDDToggle: UISwitch!
    @IBOutlet weak var shareSession: UISwitch!
    @IBOutlet weak var partyLabel: UILabel!
    @IBOutlet weak var partyLocation: UITextField!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var endLocation: UITextField!
    @IBOutlet weak var startButton: UIButton!
    
    var sessionType: String?
    var userID: String?
    var sessionID: String?
    var sessionName: String?
    var endDate: Date?
    var activeTextField: UITextField?
    var userProfileInfo: ProfileInfo?
    var startCoord: [String: Double]?
    var endCoord: [String: Double]?
    let firestoreManager = FirestoreManager.shared
    let locationManager = FirestoreManager.location
    let qToActiveSegue = "questionToActiveSegue"
    let qToGroupSegue  = "questionToGroupManage"
    let qToGroupJoinSegue = "questionsToGroupJoin"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(sessionType ?? "No Session Type Passed")
        partyLocation.delegate = self
        endLocation.delegate = self
        
        if self.sessionType == "Group" {
            startButton.setTitle("Continue", for: .normal)
        } else if self.sessionType == "Join" {
            startButton.setTitle("Join Session", for: .normal)
            
            partyLocation.isEnabled = false
            partyLabel.isHidden = true
            partyLocation.isHidden = true
            endLabel.frame = partyLabel.frame
            endLocation.frame = partyLocation.frame
        }
        
        // Do any additional setup after loading the view.
        getUserID()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Just ensuring that the search fields are getting reset at the end of a view
        partyLocation.text = nil
        endLocation.text = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // display underaged alert if user is less than 21 at current session
        let age = calcAge(birthday: (userProfileInfo?.getBirthDate())!)
        if(age < 21) {
            //show underaged alert
            AlertUtils.showAlert(title: "⚠️ Underaged Drinking ⚠️", message: "Be aware that consuming alcohol publicly under the age of 21 is illegal.", viewController: self)
        }
    }
    
    //calculates age of user
    func calcAge(birthday: String) -> Int {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        let calcAge = calendar.components(.year, from: birthdayDate!, to: now, options: [])
        let age = calcAge.year
        return age!
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
        guard (self.sessionType != nil) else {
            return
        }
        
        let defaultCoordinates = ["latitude": 30.2850, "longitude": -97.7335]
        let dispatchGroup = DispatchGroup()

        
        if self.sessionType == "Individual" || self.sessionType == "Group" {
            dispatchGroup.enter()
            let session = SessionInfo(createdBy: self.userID!,
                                      membersList: [self.userID!],
                                      sessionType: self.sessionType!,
                                      startTime: Date.now,
                                      drinksInSession: [],
                                      stillActive: true,
                                      startLocation: startCoord ?? defaultCoordinates,
                                      endLocation: endCoord ?? defaultCoordinates,
                                      ateBefore: eatenToggle.isOn,
                                      sessionName: "My Session",
                                      shareSession: shareSession.isOn)
            
            
            
            firestoreManager.addSessionInfo(userID: self.userID!, session: session) { documentID, error in
                if let error = error {
                    print("Error adding session: \(error)")
                } else if let documentID = documentID {
                    self.sessionID = documentID
                    print("Session added successfully with document ID: \(self.sessionID ?? "Value not set")")
                    dispatchGroup.leave()
                }
            }
        } else if self.sessionType == "Join" {
            // UNCOMMENT THE FOLLOWING IF YOU ARE HARDCODING A SESSION ID
            // self.sessionID = <sessionID You Want To Join>
            dispatchGroup.enter()
            let session = SessionInfo()
            session.startTime = Date.now
            session.drinksInSession = []
            session.stillActive = true
            session.startLocation = startCoord ?? defaultCoordinates
            session.endLocation = endCoord ?? defaultCoordinates
            session.ateBefore = eatenToggle.isOn
            session.shareSession = shareSession.isOn
            
            
            self.firestoreManager.getSessionInfo(userID: self.userID!, sessionDocumentID: self.sessionID!) { sessionTemp, error in
                if let error = error {
                    print("Error adding session: \(error)")
                } else if let sessionTemp = sessionTemp {
                    if sessionTemp.membersList.contains(self.userID!){
                        self.firestoreManager.setStatusActive(sessionID: self.sessionID!, userID: self.userID!, session: session) { error in
                            if error != nil {
                                let stopAlertController = UIAlertController(
                                                                    title: "Unable to Rejoin Session",
                                                                    message: "Issue when rejoining session after leaving",
                                                                    preferredStyle: .alert
                                )
        
                                stopAlertController.addAction(UIAlertAction(
                                                        title: "OK",
                                                        style: .destructive,
                                                        handler: {
                                                            (action) in
                                                            dispatchGroup.suspend()
                                                            self.dismiss(animated: true)
                                                        })
                                )
        
                                self.present(stopAlertController, animated: true)
                            } else {
                                self.sessionName = sessionTemp.sessionName
                                self.endDate = sessionTemp.endGroupSessionTime
                                dispatchGroup.leave()
                            }
                        }
                    } else {
                        self.sessionName = sessionTemp.sessionName
                        self.endDate = sessionTemp.endGroupSessionTime
                        self.firestoreManager.addMembersToSession(sessionID: self.sessionID!,
                                                             userID: self.userID!,
                                                             session: session) { error in
                            if let error = error {
                                print("Error adding member to session: \(error)")
                            } else {
                                dispatchGroup.leave()
                            }

                        }
                    }
                }
            }
            

        }
        
        dispatchGroup.notify(queue: .main) {
            if self.sessionType == "Individual" {
                self.performSegue(withIdentifier: self.qToActiveSegue, sender: self)
            } else if self.sessionType == "Group"{
                self.performSegue(withIdentifier: self.qToGroupSegue, sender: self)
            } else if self.sessionType == "Join" {
                print("Session successfully retrieved for joining with document ID: \(self.sessionID ?? "Value not set") \nUserID: \(self.userID ?? "No User")\nSessionEnd:\(self.endDate?.description ?? "no end")")
                self.performSegue(withIdentifier: self.qToGroupJoinSegue, sender: nil)
            }
        }
    }
    
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == qToActiveSegue,
           let destination = segue.destination as? ShowActiveVC {
            destination.userID = self.userID
            destination.userProfileInfo = self.userProfileInfo
            destination.sessionID = self.sessionID
            destination.isDD = self.isDDToggle.isOn
        }
        
        if segue.identifier == qToGroupSegue,
           let destination = segue.destination as? RegisterGroupSessionVC {
            destination.userID = self.userID
            destination.sessionID = self.sessionID
            destination.isDD = self.isDDToggle.isOn
        }
        
        if segue.identifier == qToGroupJoinSegue{
           
            guard let destination = segue.destination as? UINavigationController else {
                return
            }
            
            guard let finalDestination = destination.viewControllers.first as? ManageGroupSessionVC? else {
                return
            }
            
            finalDestination!.sessionName = self.sessionName!
            finalDestination!.endDate = self.endDate!
            finalDestination!.userID = self.userID
            finalDestination!.sessionID = self.sessionID
            finalDestination!.isManager = false
            finalDestination!.isDD = self.isDDToggle.isOn

        }
    }
    
    // -------- location Stuff --------- /
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        present(autocompleteController, animated: true, completion: nil)
        return false  // Prevent the default keyboard from appearing
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        activeTextField?.text = place.name
        
        let coordinates = ["latitude": place.coordinate.latitude,
                           "longitude": place.coordinate.longitude]
        
        if activeTextField == endLocation {
            endCoord = coordinates
        } else {
            startCoord = coordinates
        }
        dismiss(animated: true, completion: nil)
    }


    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Autocomplete error: \(error.localizedDescription)")
    }

    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        activeTextField?.text = nil
        if activeTextField == endLocation {
            endCoord = nil
        } else {
            startCoord = nil
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sessionDetailsToggled(_ sender: Any) {
        guard shareSession.isOn else {
            return
        }
        
        guard sessionType == "Group" || sessionType == "Join" else {
            return
        }
        
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Location access is authorized.")
        case .denied:
            print("Location access is denied. Please enable it in Settings.")
        case .notDetermined:
            print("Location access is not determined. Requesting permission...")
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location access is restricted. User cannot change the authorization status.")
        @unknown default:
            fatalError("New case added in CLLocationManager authorization status. Update the code.")
        }
    }
}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
           print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}
