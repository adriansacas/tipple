//
//  ShowActiveVC.swift
//  Tipple
//
//  Created by Andrew White on 10/15/23.
//

import UIKit

class ShowActiveVC: UIViewController {
    
    var userID: String?
    var sessionID: String?
    var userProfileInfo: ProfileInfo?
    var currentSession: SessionInfo?
    let firestoreManager = FirestoreManager.shared
    var drinkIncreaseAlert: UIAlertController?
    
    var incrementDrinkBy: Int = 0
    var runningBAC: Float = 0.0
    var runningStatus: String = "😄"
    var runningDrinkCounter: Int = 0
    let endSessionSegue = "exitToMain"
    
    let indicies = ["BAC": 0,
                    "STATUS": 1,
                    "NUMDRINK": 2]
    
    @IBOutlet weak var drinkSelectorSegmented: UISegmentedControl!
    @IBOutlet weak var statusSegmented: UISegmentedControl!
    @IBOutlet weak var navItemTitle: UINavigationItem!
    @IBOutlet weak var mainGlassIV: UIImageView!
    
    let partyModeView = PartyModeAnimationView()
    let partyModeEnabled = UserDefaults.standard.bool(forKey: "partyModeEnabled")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up an action for the drink selector
        drinkSelectorSegmented.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        // Ensure that the status segmented controller is always disabled for users (for now)
        statusSegmented.isUserInteractionEnabled = false
    }

    
    override func viewWillAppear(_ animated: Bool) {
        firestoreManager.getSessionInfo(userID: self.userID!, sessionDocumentID: self.sessionID!) { sessionTemp, error in
            if let error = error {
                print("Error adding session: \(error)")
            } else if let sessionTemp = sessionTemp {
                self.currentSession = sessionTemp
                self.navItemTitle.title = self.currentSession?.sessionName ?? ""
                
                if self.userProfileInfo == nil {
                    self.firestoreManager.getUserData(userID: self.userID!) { [weak self] (profileInfo, error) in
                        if let error = error {
                            print("Error fetching user data: \(error.localizedDescription)")
                        } else if let profileInfo = profileInfo {
                            self?.userProfileInfo = profileInfo
                            self?.setStatusInfo()
                        }
                    }
                }
                
                print("Session successfully retrieved before view appearing with document ID: \(self.sessionID ?? "Value not set")")
            }
        }
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        drinkIncreaseAlert = UIAlertController(
                                title: "How Many Drinks?",
                                message: "Please choose a value:",
                                preferredStyle: UIAlertController.Style.alert)



        var action = UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            self.incrementDrinkBy = 0
            sender.selectedSegmentIndex = -1
        })
        action.setValue(UIColor.okay, forKey:"titleTextColor")
        drinkIncreaseAlert?.addAction(action)
        
        
        action = UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            // Show party mode animation if the user is taking a shot
            if sender.titleForSegment(at: sender.selectedSegmentIndex) == "shot" && self.partyModeEnabled {
                self.partyModeView.frame = self.view.bounds
                self.view.addSubview(self.partyModeView)
                self.partyModeView.startAnimation()
            }
            
            // Create all the drinks and add them to the session
            if let drinkType = sender.titleForSegment(at: sender.selectedSegmentIndex){
                if self.incrementDrinkBy > 0{
                    self.updateDrinks(drinkType: drinkType, amount: self.incrementDrinkBy)
                    self.incrementDrinkBy = 0
                    // Update fields in the status bar
                    self.updateStatusInfo(bacValue: self.runningBAC, status: self.runningStatus, drinks: self.runningDrinkCounter)
                }
            }
            sender.selectedSegmentIndex = -1
        })
        action.setValue(UIColor.okay, forKey:"titleTextColor")
        
        drinkIncreaseAlert?.addAction(action)

        // Add a stepper to the alert controller
        drinkIncreaseAlert?.addTextField { textField in
            textField.placeholder = "Enter a value"
            textField.keyboardType = .numberPad
            textField.addTarget(self, action: #selector(self.incrementDrinkByChanged), for: .editingChanged)
        }

        self.present(drinkIncreaseAlert!, animated: true, completion: nil)
    }
    
    
    // Function to store the amount inputed by user in the text field
    @objc func incrementDrinkByChanged(_ textField: UITextField) {
        if let text = textField.text, let value = Int(text) {
            incrementDrinkBy = value
        }
    }
    
    
    // Function to update the segmented control status field at the top of the view with animation
    func updateStatusInfo(bacValue: Float, status: String, drinks: Int) {
        // Set new titles for segmented control
        statusSegmented.setTitle(String(format: "%.2f", bacValue), forSegmentAt: indicies["BAC"]!)
        statusSegmented.setTitle(status, forSegmentAt: indicies["STATUS"]!)
        statusSegmented.setTitle(String(drinks), forSegmentAt: indicies["NUMDRINK"]!)

        // Determine the new image based on bacValue
        var newImageName: String

        if bacValue < 0.04 {
            newImageName = "TippleStatus_0"
        } else if bacValue < 0.06 {
            newImageName = "TippleStatus_1"
        } else if bacValue < 0.08 {
            newImageName = "TippleStatus_2"
        } else if bacValue < 0.1 {
            newImageName = "TippleStatus_3"
        } else if bacValue < 0.12 {
            newImageName = "TippleStatus_4"
        } else if bacValue < 0.14 {
            newImageName = "TippleStatus_5"
        } else {
            newImageName = "TippleStatus_6"
        }

        // Perform animation
        UIView.transition(with: mainGlassIV,
                          duration: 0.3, // You can adjust the duration as needed
                          options: .transitionCrossDissolve,
                          animations: {
                              self.mainGlassIV.image = UIImage(named: newImageName)
                          },
                          completion: nil)
    }
    
    
    func setStatusInfo(){
        let drinks: [DrinkInfo] = self.currentSession!.drinksInSession
        var tempBAC: Float = 0
        if !drinks.isEmpty{
            let latestDrink = drinks.max(by: { $0.timeAt < $1.timeAt })
            tempBAC = latestDrink!.bacAtTime
        }
        
        self.runningDrinkCounter = drinks.count
        self.runningBAC = tempBAC
        self.runningStatus = calculateStatus()
        
        updateStatusInfo(bacValue: self.runningBAC,
                         status: self.runningStatus,
                         drinks: self.runningDrinkCounter)
    }
    
    func updateDrinks(drinkType: String, amount: Int) {
        print("Drink: \(drinkType) x \(amount)")
        print("Creating the drinkObjects to add to a given session")
        
        let prevDrinkAmount = self.runningDrinkCounter
        self.runningDrinkCounter += amount      // Increment the running amount of drinks
        self.runningBAC = calculateBac()      // Calculate the new BAC
        self.runningStatus = calculateStatus()  // Calculate the new status based on BAC
        
        var drinkObjects: [DrinkInfo] = []
        
        for drinkNum in 1...amount {
            let tempDrink = DrinkInfo(drinkType: drinkType,
                                      drinkNumIn: prevDrinkAmount + drinkNum,
                                      bacAtTime: self.runningBAC)
            
            drinkObjects.append(tempDrink)
        }
        
        // Update the session object with new drinks
        self.currentSession?.drinksInSession.append(contentsOf: drinkObjects)

        guard self.sessionID != nil else {
            print("NO SESSION ID STORED -- NOT UPDATING FIREBASE")
            return
        }
        
        
        // Update Firestore with the new drinks
        firestoreManager.updateDrinksInSession(userID: self.userID!,
                                               sessionID: self.sessionID!,
                                               drinksToAdd: drinkObjects) { error in
            if let error = error {
                print("Error adding session: \(error)")
            } else {
                print("Session updated with : \(self.sessionID ?? "")")
            }
        }
        
    }
    
    
    func calculateBac() -> Float {
         guard self.userProfileInfo != nil else {
             print("Do Not Have User Profile Information")
             return 0.0
         }
         
         let r: Float = self.userProfileInfo!.gender == "Male" ? 0.68 : 0.55
         let alcConsumedInGrams = Float(self.runningDrinkCounter * 14)
         let bodyWeight = Float(self.userProfileInfo!.weight) * 0.45359237

         let bac = (alcConsumedInGrams / (bodyWeight * 1000.0 * r)) * 100.0

         return bac
    }
    
    func calculateStatus() -> String {
        if self.runningBAC < 0.08 {
            return "😀"
        } else if (self.runningBAC < 0.12) {
            AlertUtils.showAlert(title: "Slow down!", message: "You've had a few drinks, take a break and drink some water", viewController: self)
            return "🤢"
        } else {
            AlertUtils.showAlert(title: "Tap out", message: "Time to stop drinking, make sure to hydrate!", viewController: self)
            return "💀"
        }
    }

    @IBAction func exitSession(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Finish Session",
            message: "Are you sure you want to finish your session?",
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        action.setValue(UIColor.okay, forKey:"titleTextColor")
        
        // Add a "Cancel" action
        alertController.addAction(action)

        // Add a "Finish" action
        // TODO: Mark a session as finished one they exit to the main page.
        alertController.addAction(UIAlertAction(title: "Finish", style: .destructive) { _ in
            self.performSegue(withIdentifier: self.endSessionSegue, sender: self)
        })

        // Present the alert
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.endSessionSegue, let nextVC = segue.destination as? HomeViewController{
            nextVC.saveOnKeychain = false
            nextVC.saveEmail = ""
            nextVC.savePassword = ""
            
            // handle firebase marking of end session
            firestoreManager.endSessionForUser(userID: self.userID!,
                                               sessionID: self.sessionID!) { error in
                if let error = error {
                    print("Error ending session: \(error)")
                }
            }
        }
    }
}
