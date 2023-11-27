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
        
//        //TODO: comment out after debugging, this works
//        print("saveOnKeychain: \(saveOnKeychain ?? false)")
//        print("saveEmail: \(saveEmail ?? "blank")")
//        print("savePassword: \(savePassword ?? "blank")")
        
        if(saveOnKeychain! && saveEmail! != "" && savePassword! != ""){
            print("can save on keychain, calling presentSheet()")
            
            //call only if the query for 'tipple.com is empty'
            presentSheet()
        } else {
            print("login info already exists on keychain, no overwrite")
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
            
            keychainAlert.addAction(
                UIAlertAction(
                    title: "Save Login Info",
                    style: .default,
                    handler: {
                        action in self.saveLoginToKeychain()
                    }
                )
            )
            
            keychainAlert.addAction(
                UIAlertAction(
                    title: "Not Now",
                    style: .cancel)
            )
            self.present(keychainAlert, animated: true)
        }
    }
    
    func saveLoginToKeychain(){
        print("saving info to keychain")
        
        let encryptedPassword = savePassword?.data(using: String.Encoding.utf8)!
        
        //create add query
        var query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: saveEmail!,
                                    kSecAttrServer as String: "www.tipple.com",
                                    kSecValueData as String: encryptedPassword!]
        
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess
        else {
            print("ERROR something went wrong!!")
            return
        }
        
        print("successfully saved!")
    }
    
    
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

        controller.addAction(individualSessionAction)
        
        controller.addAction(UIAlertAction(
            title: "Group Session",
            style: .default
        ) { (action) in
            self.sessionType = "Group"
            self.performSegue(withIdentifier: "individualToQASegue", sender: self)
        }
                             
        )
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
