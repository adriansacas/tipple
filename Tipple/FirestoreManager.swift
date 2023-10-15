//
//  FirestoreManager.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/14/23.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirestoreManager {

    static let shared = FirestoreManager()

    private let db = Firestore.firestore()
    private let usersCollection = "users"

    private init() {
        // Private initializer to ensure it's a singleton
    }

    // Function to add a new user document
    func createUserDocument(userID: String, firstName: String, lastName: String, phoneNumber: String, birthDay: Date, gender: String, heightFeet: Int, heightInches: Int, weight: Int, email: String) {
        let userRef = db.collection(usersCollection).document(userID)
        let userData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "birthDay": birthDay,
            "gender": gender,
            "heightFeet": heightFeet,
            "heightInches": heightInches,
            "weight": weight,
            "email": email
        ]
        
        userRef.setData(userData) { error in
            if let error = error {
                print("Error creating user document: \(error)")
            } else {
                print("User document created successfully for user \(userID)")
            }
        }
    }

    // Function to retrieve user data by user ID
//    func getUserData(userID: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
//        let userRef = db.collection(usersCollection).document(userID)
//        userRef.getDocument { (document, error) in
//            if let error = error {
//                completion(.failure(error))
//            } else if let document = document, document.exists {
//                if let userData = document.data() {
//                    completion(.success(userData))
//                } else {
//                    completion(.failure(NSError(domain: "", code: 0, userInfo: ["message": "User data not found"])))
//                }
//            } else {
//                completion(.failure(NSError(domain: "", code: 0, userInfo: ["message": "User document not found"])))
//            }
//        }
//    }
    
    // Function to retrieve user data and parse it into a ProfileInfo object
    func getUserData(userID: String, completion: @escaping (ProfileInfo?, Error?) -> Void) {
        let userRef = db.collection(usersCollection).document(userID)
        userRef.getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
            } else if let document = document, document.exists {
                if let userData = document.data(),
                   let firstName = userData["firstName"] as? String,
                   let lastName = userData["lastName"] as? String,
                   let phoneNumber = userData["phoneNumber"] as? String,
                   let birthDayTimestamp = userData["birthDay"] as? Timestamp,
                   let gender = userData["gender"] as? String,
                   let heightFeet = userData["heightFeet"] as? Int,
                   let heightInches = userData["heightInches"] as? Int,
                   let weight = userData["weight"] as? Int{
                    let birthDay = birthDayTimestamp.dateValue()
                    let profileInfo = ProfileInfo(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, birthDay: birthDay, gender: gender, heightFeet: heightFeet, heightInches: heightInches, weight: weight)
                    completion(profileInfo, nil)
                } else {
                    completion(nil, NSError(domain: "", code: 0, userInfo: ["message": "User data not found or is invalid"]))
                }
            } else {
                completion(nil, NSError(domain: "", code: 0, userInfo: ["message": "User document not found"]))
            }
        }
    }

    // Add more functions for updating and deleting user data as needed

    // Example function for updating user data
    func updateUserDocument(userID: String, updatedData: [String: Any]) {
        let userRef = db.collection(usersCollection).document(userID)
        userRef.updateData(updatedData) { error in
            if let error = error {
                print("Error updating user document: \(error)")
            } else {
                print("User document updated successfully for user \(userID)")
            }
        }
    }

    // Example function for deleting user data
    func deleteUserDocument(userID: String) {
        let userRef = db.collection(usersCollection).document(userID)
        userRef.delete { error in
            if let error = error {
                print("Error deleting user document: \(error)")
            } else {
                print("User document deleted successfully for user \(userID)")
            }
        }
    }
}
