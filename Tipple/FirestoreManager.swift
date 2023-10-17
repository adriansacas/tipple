//
//  FirestoreManager.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/14/23.
//

import Foundation
import Firebase
import FirebaseFirestore


/*
 EXAMPLE:
    let firestoreManager = FirestoreManager.shared
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    if let birthDate = dateFormatter.date(from: "2024-10-14"), let userID = Auth.auth().currentUser?.uid, let email = Auth.auth().currentUser?.email {
         firestoreManager.createUserDocument(
             userID: userID,
             firstName: "John",
             lastName: "Doe",
             phoneNumber: "1234567890",
             birthday: birthDate,
             gender: "Man",
             heightFeet: 6,
             heightInches: 2,
             weight: 180,
             email: email,
             profileImageURL: ""
         )
    } else {
     print("Invalid date format or invalid userid")
    }
 */
class FirestoreManager {
    
    static let shared = FirestoreManager()
    
    private let db = Firestore.firestore()
    private let usersCollection = "users"
    private let sessionsPerUserCollection = "sessions"
    
    private init() {
        // Private initializer to ensure it's a singleton
    }
    
    // Function to add a new user document
    func createUserDocument(userID: String, firstName: String, lastName: String, phoneNumber: String, birthday: Date, gender: String, heightFeet: Int, heightInches: Int, weight: Int, email: String, profileImageURL: String = "") {
        let userRef = db.collection(usersCollection).document(userID)
        var userData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "birthday": birthday,
            "gender": gender,
            "heightFeet": heightFeet,
            "heightInches": heightInches,
            "weight": weight,
            "email": email
        ]
        
        // Add profileImageURL to userData only if it's not an empty string
        if !profileImageURL.isEmpty {
            userData["profileImageURL"] = profileImageURL
        }
        
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
                   let birthdayTimestamp = userData["birthday"] as? Timestamp,
                   let gender = userData["gender"] as? String,
                   let heightFeet = userData["heightFeet"] as? Int,
                   let heightInches = userData["heightInches"] as? Int,
                   let profileImageURL = userData["profileImageURL"] as? String,
                   let weight = userData["weight"] as? Int{
                    let birthday = birthdayTimestamp.dateValue()
                    let profileInfo = ProfileInfo(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, birthday: birthday, gender: gender, heightFeet: heightFeet, heightInches: heightInches, weight: weight, profileImageURL: profileImageURL)
                    completion(profileInfo, nil)
                } else {
                    completion(nil, NSError(domain: "", code: 0, userInfo: ["message": "User data not found or is invalid"]))
                }
            } else {
                completion(nil, NSError(domain: "", code: 0, userInfo: ["message": "User document not found"]))
            }
        }
    }
    
    // Function for updating user data
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
    
    // Function for deleting user data
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
    
    
    /* ------------     Session Firebase Stuff      ------------*/
    
    // Function for getting all sessions based on a profile
    func getAllSessions(userID: String, completion: @escaping ([SessionInfo]?, Error?) -> Void) {
        let userDocRef = db.collection(usersCollection).document(userID)
        let sessionsCollectionRef = userDocRef.collection(sessionsPerUserCollection)
        
        sessionsCollectionRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                var sessionInfoArray: [SessionInfo] = []
                
                for document in querySnapshot!.documents {
                    let data = document.data()
                    // Map data to SessionInfo object
                    if let startTimeTimestamp = data["startTime"] as? Timestamp,
                       let sessionType = data["sessionType"] as? String,
                       let drinksInSessionData = data["drinksInSession"] as? [[String: Any]] {
                        
                        let startTime = startTimeTimestamp.dateValue()
                        var drinksInSession: [DrinkInfo] = []
                        
                        for drinkData in drinksInSessionData {
                            // Map data to DrinkInfo object
                            if let drinkType = drinkData["type"] as? String,
                               let timeAtTimestamp = drinkData["timeAt"] as? Timestamp,
                               let drinkNum = drinkData["drinkNum"] as? Int,
                               let bacAtTime = drinkData["bacAtTime"] as? Float {
                                
                                let timeAt = timeAtTimestamp.dateValue()
                                let drinkInfo = DrinkInfo(drinkType: drinkType, drinkNum: drinkNum, bacAtTime: bacAtTime, timeAt: timeAt)
                                drinksInSession.append(drinkInfo)
                            }
                        }
                        
                        let session = SessionInfo(startTime: startTime, sessionType: sessionType, drinksInSession: drinksInSession)
                        sessionInfoArray.append(session)
                    }
                }
                completion(sessionInfoArray, nil)
            }
        }
    }
    
    
    // Adds a session for a given userID
    func addSessionInfo(userID: String, session: SessionInfo, completion: @escaping (String?, Error?) -> Void) {
        let userDocRef = db.collection(usersCollection).document(userID)
        
        // Convert the session to a dictionary
        var sessionData: [String: Any] = [
            "startTime": Timestamp(date: session.startTime),
            "sessionType": session.sessionType,
            // Maps all current drinks to a dictionary
            "drinksInSession": session.drinksInSession.map { drink in
                return [
                    "type": drink.type,
                    "timeAt": Timestamp(date: drink.timeAt),
                    "drinkNum": drink.drinkNum,
                    "bacAtTime": drink.bacAtTime
                ]
            }
        ]
        
        // Add optional properties if they exist
        if let startLocation = session.startLocation {
            sessionData["startLocation"] = startLocation
        }
        
        if let endLocation = session.endLocation {
            sessionData["endLocation"] = endLocation
        }
        
        if let ateBefore = session.ateBefore {
            sessionData["ateBefore"] = ateBefore
        }
        
        if let sessionName = session.sessionName {
            sessionData["sessionName"] = sessionName
        }
        
        if let shareSession = session.shareSession {
            sessionData["shareSession"] = shareSession
        }
        
        if let membersList = session.membersList {
            sessionData["membersList"] = membersList
        }
        
        // Add the session data to the "sessions" subcollection under the user's document
        let sessionsCollectionRef = userDocRef.collection(sessionsPerUserCollection)
        
        var addedDocumentRef: DocumentReference?
        
        // Add the document and get its reference
        addedDocumentRef = sessionsCollectionRef.addDocument(data: sessionData) { error in
            if let error = error {
                completion(nil, error)
            } else if let documentID = addedDocumentRef?.documentID {
                // Get the document ID from the reference and pass it in the completion
                completion(documentID, nil)
            }
        }
    }
    
    // Function to update the drinks of a current session based on a sessionID
    func updateDrinksInSession(userID: String, sessionID: String, drinksToAdd: [DrinkInfo], completion: @escaping (Error?) -> Void) {
        print("Attempting Drink update with IDS\n\t-- USERID: \(userID), sessionID: \(sessionID)")
        let userDocRef = db.collection(usersCollection).document(userID)
        let sessionsCollectionRef = userDocRef.collection(sessionsPerUserCollection)
        
        // Build a reference to the specific session document
        let sessionDocRef = sessionsCollectionRef.document(sessionID)
        
        sessionDocRef.getDocument { (document, error) in
            if let error = error {
                completion(error)
            } else if let document = document, document.exists {
                // Get the existing drinksInSession array
                var drinksInSession = document.data()?["drinksInSession"] as? [[String: Any]] ?? []
                

                // Convert the DrinkInfo objects to dictionary representations
                let drinkInfoData = drinksToAdd.map { drink in
                    return [
                        "type": drink.type,
                        "timeAt": Timestamp(date: drink.timeAt),
                        "drinkNum": drink.drinkNum,
                        "bacAtTime": drink.bacAtTime
                    ]
                }
                
                // Append the new drinks to the drinksInSession array
                drinksInSession.append(contentsOf: drinkInfoData)
                
                // Update the "drinksInSession" field in the document
                sessionDocRef.updateData(["drinksInSession": drinksInSession]) { updateError in
                    if let updateError = updateError {
                        completion(updateError)
                    } else {
                        completion(nil) // Successfully updated the field
                    }
                }
            } else {
                // Handle the case where the session document doesn't exist
                let notFoundError = NSError(domain: "Document Not Found", code: 404, userInfo: nil)
                completion(notFoundError)
            }
        }
    }
}
