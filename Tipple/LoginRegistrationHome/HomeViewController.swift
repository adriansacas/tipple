//
//  HomeViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/12/23.
//

import UIKit

class HomeViewController: UIViewController {
    
    var sessionType: String?
    
    //add variables that get passed from login/sign up to home
    var saveOnKeychain: Bool?
    var saveEmail: String?
    var savePassword: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //check if login credentials already exist on the keychain and has valid email and password
        if(saveOnKeychain! && saveEmail! != "" && savePassword! != ""){
            
            //call only if the query for 'www.tipple.com is empty'
            presentSheet()
        }
    }
    
    //show action sheet to save login information to keychain
    func presentSheet() {
        
        DispatchQueue.main.async {
            let keychainAlert = UIAlertController(
                title: "Would you like to save the login information to your Device Keychain to enable FaceID login?",
                message: "You can view and remove login information in Passwords settings.",
                preferredStyle: .actionSheet
            )
            
            
            var action = UIAlertAction(
                title: "Save Login Info",
                style: .default,
                handler: {
                    action in self.saveLoginToKeychain()
                }
            )
            action.setValue(UIColor.okay, forKey:"titleTextColor")
            keychainAlert.addAction(action)
            
            action = UIAlertAction(title: "Not Now", style: .cancel)
            action.setValue(UIColor.okay, forKey:"titleTextColor")
            
            keychainAlert.addAction(action)
            self.present(keychainAlert, animated: true)
        }
    }
    
    func saveLoginToKeychain(){
        
        let encryptedPassword = savePassword?.data(using: String.Encoding.utf8)!
        
        //create add query
        var query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: saveEmail!,
                                    kSecAttrServer as String: "www.tipple.com",
                                    kSecValueData as String: encryptedPassword!]
        
        
        let status = SecItemAdd(query as CFDictionary, nil)
    }
    
    
    //display options for starting and individual or group session
    @IBAction func startSessionButtonPressed(_ sender: Any) {
        
        let controller = UIAlertController(
            title: "Choose Session Type",
            message: "Choose the session you want to start",
            preferredStyle: .alert
        )
        
        let individualSessionAction = UIAlertAction(
            title: "Individual Session",
            style: .default
        ) { (action) in
            self.sessionType = "Individual"
            self.performSegue(withIdentifier: "individualToQASegue", sender: self)
        }
        individualSessionAction.setValue(UIColor.okay, forKey:"titleTextColor")
        
        controller.addAction(individualSessionAction)
        
        let groupSessionAction = UIAlertAction(
            title: "Group Session",
            style: .default
        ) { (action) in
            self.sessionType = "Group"
            self.performSegue(withIdentifier: "individualToQASegue", sender: self)
        }
        groupSessionAction.setValue(UIColor.okay, forKey:"titleTextColor")
        
        controller.addAction(groupSessionAction)
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .default
        )
        cancelAction.setValue(UIColor.okay, forKey:"titleTextColor")
        controller.addAction(cancelAction)
        
        present(controller, animated: true)
    }
    
    @IBAction func previousSessionButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "homeToPrevSession", sender: nil)
    }
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        defaults.set(false, forKey: "tippleStayLoggedIn")
        performSegue(withIdentifier: "homeToLoginSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "individualToQASegue",
           let destination = segue.destination as? QuestionnaireVC {
            destination.sessionType = self.sessionType
        }
    }
}
