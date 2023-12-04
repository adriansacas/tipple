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
        guard let currentUser = Auth.auth().currentUser else {
            AlertUtils.showSessionExpiredAlert(viewController: viewController)
            completion(nil, nil)
            return
        }
        
        currentUser.reload(completion: { [weak self] error in
            if let error = error as NSError? {
                if self?.isCredentialInvalidError(error) == true {
                    // Handle the invalid credential scenario
                    AlertUtils.showSessionExpiredAlert(viewController: viewController)
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
}

