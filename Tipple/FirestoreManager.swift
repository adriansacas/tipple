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
             email: email
         )
    } else {
     print("Invalid date format or invalid userid")
    }
 */
class FirestoreManager {
    
    static let shared = FirestoreManager()
    
    private let db = Firestore.firestore()
    private let usersCollection = "users"
    private let sessionCollection = "sessions"
    private let memberColInSess = "membersList"
    
    private init() {
        // Private initializer to ensure it's a singleton
    }
    
    // Function to add a new user document
    func createUserDocument(userID: String, firstName: String, lastName: String, phoneNumber: String, birthday: Date, gender: String, heightFeet: Int, heightInches: Int, weight: Int, email: String, profileImageURL: String, sessionIDS: [String]) {
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
            "email": email,
            "profileImageURL": profileImageURL,
            "sessionIDS": sessionIDS
        ]
        
        userRef.setData(userData) { error in
            if let error = error {
                print("Error creating user document: \(error)")
            } else {
                print("User document created successfully for user \(userID)")
            }
        }
    }
    
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
                   let weight = userData["weight"] as? Int,
                   let sessionIDS = userData["sessionIDS"] as? [String] {
                    let birthday = birthdayTimestamp.dateValue()
                    let profileInfo = ProfileInfo(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, birthday: birthday, gender: gender, heightFeet: heightFeet, heightInches: heightInches, weight: weight, profileImageURL: profileImageURL, sessionIDS: sessionIDS)
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
        
        userDocRef.getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
            } else if let document = document, document.exists {
                if let userData = document.data(),
                   let sessionIDS = userData["sessionIDS"] as? [String] {
                    
                    let sessionDBRef = self.db.collection(self.sessionCollection)
                    var sessionsFetched = 0         // Track the number of fetched sessions
                    var sessions: [SessionInfo] = []
                    
                    for sessionID in sessionIDS {
                        var memberList = [String]()
                        let sessionRef = sessionDBRef.document(sessionID)
                        sessionRef.getDocument { (sessionDocument, sessionError) in
                            if let sessionError = sessionError {
                                completion(nil, sessionError)
                                return
                            }
                            
                            if let sessionDocument = sessionDocument, sessionDocument.exists,
                               let sessionData = sessionDocument.data(){
                                let sessionTemp = SessionInfo()
                                sessionTemp.sessionDocID = sessionDocument.documentID                                
                                if let createdBy = sessionData["createdBy"] as? String {
                                    sessionTemp.createdBy = createdBy
                                }
                                
                                if let endTimeTimestamp = sessionData["endTime"] as? Timestamp {
                                    sessionTemp.endGroupSessionTime = endTimeTimestamp.dateValue()
                                    
                                }
                                
                                if let sessionName = sessionData["sessionName"] as? String {
                                    sessionTemp.sessionName = sessionName
                                }
                                
                                if let sessionType = sessionData["sessionType"] as? String{
                                    sessionTemp.sessionType = sessionType
                                }
                                
                                let membersCollection = sessionRef.collection(self.memberColInSess)
                                membersCollection.getDocuments { (memberDocuments, memberError) in
                                    if let memberError = memberError {
                                        completion(nil, memberError)
                                        return
                                    }
                                    
                                    for doc in memberDocuments!.documents {
                                        let memberID = doc.documentID
                                        let memberDoc = doc.data()
                                        if memberID == userID {
                                            if let activeSession = memberDoc["activeSession"] as? Bool {
                                                sessionTemp.stillActive = activeSession
                                            }
                                            
                                            if let ateBefore = memberDoc["ateBefore"] as? Bool {
                                                sessionTemp.ateBefore = ateBefore
                                            }
                                            
                                            if let endLocation = memberDoc["endLocation"] as? String {
                                                sessionTemp.endLocation = endLocation
                                            }
                                            
                                            if let startLocation = memberDoc["startLocation"] as? String {
                                                sessionTemp.startLocation = startLocation
                                            }
                                            var drinksInSession: [DrinkInfo] = []
                                            
                                            if let drinksInSessionData = memberDoc["drinksInSession"] as? [[String: Any]] {
                                                for drinkData in drinksInSessionData {
                                                    if let type = drinkData["type"] as? String,
                                                       let timeAtTimestamp = drinkData["timeAt"] as? Timestamp,
                                                       let drinkNum = drinkData["drinkNum"] as? Int,
                                                       let bacAtTime = drinkData["bacAtTime"] as? Float {
                                                        let timeAt = timeAtTimestamp.dateValue()
                                                        let drinkInfo = DrinkInfo(drinkType: type, drinkNum: drinkNum, bacAtTime: bacAtTime, timeAt: timeAt)
                                                        drinksInSession.append(drinkInfo)
                                                    }
                                                }
                                            }
                                            
                                            if let startTimeTimestamp = memberDoc["startTime"] as? Timestamp {
                                                sessionTemp.startTime = startTimeTimestamp.dateValue()
                                            }
                                            var currentSymptoms = [String]()
                                            if let symptomsList = memberDoc["symptomsList"] as? [String]{
                                                currentSymptoms.append(contentsOf: symptomsList)
                                            }
                                            
                                            sessionTemp.symptomsList = currentSymptoms
                                            sessionTemp.drinksInSession = drinksInSession
                                            
                                        }
                                        memberList.append(memberID)
                                    }
                                    sessionTemp.membersList = memberList
                                    sessions.append(sessionTemp)
                                    sessionsFetched += 1
                                    
                                    if sessionsFetched == sessionIDS.count {
                                        // All sessions have been fetched
                                        completion(sessions, nil)
                                    }
                                }
                            } else {
                                completion(nil, NSError(domain: "", code: 0, userInfo: ["message": "User data not found or is invalid"]))
                            }
                        }
                    }
                }
            }
        }
    }
            
    
    // Adds a member to a given session document
    func addMembersToSession(sessionID: String, userID: String, session: SessionInfo, completion: @escaping (Error?) -> Void) {
        let sessionDBRef = db.collection(sessionCollection)
        
        // Create a reference to the session document
        let sessionRef = sessionDBRef.document(sessionID)
        
        // Create a reference to the membersList subcollection within the session
        let membersListRef = sessionRef.collection(memberColInSess)
        
        // Extract the member data from the SessionInfo object
        let memberData: [String: Any] = [
            "startTime": Timestamp(date: session.startTime),
            "activeSession": session.stillActive,
            "startLocation": session.startLocation ?? "",
            "endLocation": session.endLocation ?? "",
            "ateBefore": session.ateBefore ?? false,
            "symptomsList": session.symptomsList ?? [],
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

        // Create a reference to the new member document with the specified userID
        let newMemberRef = membersListRef.document(userID)
        
        // Set the data for the new member document
        newMemberRef.setData(memberData) { error in
            if let error = error {
                completion(error)
            } else {
                
                // Now To Add This SessionID to the users list of SessionIDS
                let userDBREF = self.db.collection(self.usersCollection).document(userID)
                
                userDBREF.getDocument { (document, error) in
                    if let error = error {
                        completion(error)
                    } else if let document = document, document.exists {
                        // Get the existing array
                        var currentSessions = document.data()?["sessionIDS"] as? [String] ?? []
                                        
                        currentSessions.append(sessionID)
                        
                        userDBREF.updateData(["sessionIDS": currentSessions]) { updateError in
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
    }
    
    
    // Adds a session for a given userID
    func addSessionInfo(userID: String, session: SessionInfo, completion: @escaping (String?, Error?) -> Void) {
        // Create a reference to the main "Sessions" collection
        let sessionsCollectionRef = db.collection(sessionCollection)
        
        // Convert the session to a dictionary
        var sessionData: [String: Any] = [
            "createdBy": userID,
            "sessionName": session.sessionName ?? "",
            "sessionType": session.sessionType,
        ]

        // Add optional properties if they exist
        if let shareSession = session.shareSession {
            sessionData["shareSession"] = shareSession
        }

        // Add the session data to the "Sessions" collection
        var addedDocumentRef: DocumentReference?

        // Add the document and get its reference
        addedDocumentRef = sessionsCollectionRef.addDocument(data: sessionData) { error in
            if let error = error {
                completion(nil, error)
            } else if let documentID = addedDocumentRef?.documentID {
                // Get the document ID from the reference and pass it in the completion
                // After adding the session document, add members to the session
                self.addMembersToSession(sessionID: documentID, userID: userID, session: session) { addMembersError in
                    if let addMembersError = addMembersError {
                        completion(nil, addMembersError)
                    } else {
                        session.sessionDocID = documentID
                        completion(documentID, nil)
                    }
                }
            }
        }
    }
    
    // Function to update the drinks of a current session based on a sessionID
    func updateDrinksInSession(userID: String, sessionID: String, drinksToAdd: [DrinkInfo], completion: @escaping (Error?) -> Void) {
        print("Attempting Drink update with IDS\n\t-- USERID: \(userID), sessionID: \(sessionID)")
        
        
        let userDocRef = db.collection(sessionCollection).document(sessionID).collection(memberColInSess).document(userID)
        
        userDocRef.getDocument { (document, error) in
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
                userDocRef.updateData(["drinksInSession": drinksInSession]) { updateError in
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
    
    // Function to update the symptoms of a given session
    func updateSymptomsForSession(userID: String, sessionID: String, symptoms: [String], completion: @escaping (Error?) -> Void) {
        print("Attempting symptoms update with IDS\n\t-- USERID: \(userID), sessionID: \(sessionID)")
        
        
        let userDocRef = db.collection(sessionCollection).document(sessionID).collection(memberColInSess).document(userID)
        
        userDocRef.getDocument { (document, error) in
            if let error = error {
                completion(error)
            } else if let document = document, document.exists {
                // Get the existing symptoms array
                var currentSymptoms = document.data()?["symptomsList"] as? [String] ?? []
            
                
                // Append the new symptoms to the symptoms array
                currentSymptoms.append(contentsOf: symptoms)
                
                // Update the "drinksInSession" field in the document
                userDocRef.updateData(["symptomsList": currentSymptoms]) { updateError in
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
    
    // Function to pull information for group members list tableview
    func pullGroupMembers(userID: String, sessionID: String, completion: @escaping ([String: [String: Any]]?, Error?) -> Void) {
        let sessionDocRef = db.collection(sessionCollection).document(sessionID).collection(memberColInSess)
        
        var dictOfMembers: [String: [String: Any]] = [:]

        
        sessionDocRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error) // Handle the error and pass it to the completion block
            } else {
                for document in querySnapshot!.documents {
                    let memberDoc = document.data()
                    let memberID = document.documentID
                    if memberID == userID {
                        continue
                    }
                    
                    var memberDict = ["status" : false,
                                      "contactInfo" : "",
                                      "BAC" : "",
                                      "name": ""]
                    
                    /* Store whether this user is still active or not */
                    if let activeSession = memberDoc["activeSession"] as? Bool {
                        memberDict["status"] = activeSession
                    }
                    
                    /* Pull and the current drinks in order to calculate the BAC for the user */
                    var drinksInSession: [DrinkInfo] = []
                    if let drinksInSessionData = memberDoc["drinksInSession"] as? [[String: Any]] {
                        for drinkData in drinksInSessionData {
                            if let type = drinkData["type"] as? String,
                               let timeAtTimestamp = drinkData["timeAt"] as? Timestamp,
                               let drinkNum = drinkData["drinkNum"] as? Int,
                               let bacAtTime = drinkData["bacAtTime"] as? Float {
                                let timeAt = timeAtTimestamp.dateValue()
                                let drinkInfo = DrinkInfo(drinkType: type, drinkNum: drinkNum, bacAtTime: bacAtTime, timeAt: timeAt)
                                drinksInSession.append(drinkInfo)
                            }
                        }
                    }
                    if !drinksInSession.isEmpty {
                        if let mostRecentDrink = drinksInSession.max(by: { $0.timeAt < $1.timeAt }) {
                            // `mostRecentDrink` now contains the `DrinkInfo` with the most recent timestamp
                            memberDict["BAC"] = mostRecentDrink.getBAC()
                        } else {
                            // The `drinksInSession` array is empty
                            memberDict["BAC"] = "0.00"
                        }
                    } else {
                        memberDict["BAC"] = "0.00"
                    }
                    
                    self.getUserData(userID: userID) { (profileInfo, error) in
                        if let error = error {
                            memberDict["contactInfo"] = ""
                            memberDict["name"] = ""
                        } else if let tempProfile = profileInfo {
                            memberDict["contactInfo"] = tempProfile.phoneNumber
                            memberDict["name"] = tempProfile.firstName + " " + tempProfile.lastName

                        } else {
                            memberDict["contactInfo"] = ""
                            memberDict["name"] = ""
                        }
                    }
                    // Append the memberDict to dictOfMembers
                    dictOfMembers[memberID] = memberDict
                }
                completion(dictOfMembers, nil)
            }
        }
    }

}
