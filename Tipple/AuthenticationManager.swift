//
//  AuthenticationManager.swift
//  Tipple
//
//  Created by Adrian Sanchez on 12/2/23.
//

import UIKit
import FirebaseAuth

class AuthenticationManager {
    
    static let shared = AuthenticationManager()

    private init() {}

    // Retrieves and validates the current user information
    func getCurrentUser(viewController: UIViewController, completion: @escaping (User?, Error?) -> Void) {
        let currentUser = Auth.auth().currentUser
        currentUser?.reload(completion: { [weak self] error in
            if let error = error as NSError? {
                if self?.isCredentialInvalidError(error) == true {
                    // Handle the invalid credential scenario
                    self?.promptUserForReauthentication()
                    completion(nil, error)
                } else {
                    // Handle other errors
                    completion(nil, error)
                }
            } else {
                // User is valid and authenticated
                completion(currentUser, nil)
            }
        })
    }

    // Helper function to check for specific invalid credential error
    private func isCredentialInvalidError(_ error: NSError) -> Bool {
        return error.domain == AuthErrorDomain && error.code == AuthErrorCode.userTokenExpired.rawValue
    }

    // Function to prompt the user to reauthenticate
    private func promptUserForReauthentication() {
        // Implementation depends on your app's UI framework
        // This could be showing an alert, presenting a modal view controller, etc.
        // Example:
        // showAlert("Your session has expired. Please log in again.")
    }
    
    // Example function to show an alert (adjust based on your app's UI framework)
    private func showAlert(_ message: String) {
        // Implementation of alert presentation
    }
}

