//
//  FirestoreManager.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/14/23.
//

import Foundation
import CoreLocation
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
    static let location = CLLocationManager()
    
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
        let userData: [String: Any] = [
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
                                            
                                            if let endLocationGeoPoint = memberDoc["endLocation"] as? GeoPoint {
                                                let endLocation = ["latitude": endLocationGeoPoint.latitude,
                                                                   "longitude": endLocationGeoPoint.longitude]
                                                    sessionTemp.endLocation = endLocation
                                            }
                                            
                                            if let startLocationGeoPoint = memberDoc["startLocation"] as? GeoPoint {
                                                let startLocation = ["latitude": startLocationGeoPoint.latitude,
                                                                         "longitude": startLocationGeoPoint.longitude]
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
        var memberData: [String: Any] = [
            "startTime": Timestamp(date: session.startTime),
            "activeSession": session.stillActive,
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
        
        // Add optional properties if they exist
        if let shareSession = session.shareSession {
            memberData["shareSession"] = shareSession
        }
        
        // Add startLocation to memberData if it exists
        if let startLocation = session.startLocation {
            memberData["startLocation"] = GeoPoint(latitude: startLocation["latitude"]!, 
                                                   longitude: startLocation["longitude"]!)
        }

        // Add endLocation to memberData if it exists
        if let endLocation = session.endLocation {
            memberData["endLocation"] = GeoPoint(latitude: endLocation["latitude"]!, 
                                                 longitude: endLocation["longitude"]!)
        }
        
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
        
        
        if let endSession = session.endGroupSessionTime {
            sessionData["endTime"] = endSession
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
                currentSymptoms = symptoms
                
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
    
    // Function to edit group session details (if you are the main person
    func updateGroupSession(userID: String, sessionID: String, fields: [String: Any], completion: @escaping (Error?) -> Void) {
        print("Attempting to update group session with IDS\n\t-- USERID: \(userID), sessionID: \(sessionID)")
        
        
        let sessionDocRef = db.collection(sessionCollection).document(sessionID)
        
        sessionDocRef.getDocument { (document, error) in
            if let error = error {
                completion(error)
            } else if let document = document, document.exists {
                let sessionData = document.data()
                
                let createdBy = sessionData!["createdBy"] as? String
                
                if createdBy != userID {
                    print("This should not happen. Non group leader attempting to edit session")
                }
                
                
                sessionDocRef.updateData(fields) { updateError in
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
    
    // Function to edit group session details (if you are the main person
    func endSessionForUser(userID: String, sessionID: String,  completion: @escaping (Error?) -> Void) {
        let sessionDocRef = db.collection(sessionCollection).document(sessionID)
        
        sessionDocRef.getDocument { (document, error) in
            if let error = error {
                completion(error)
            } else if let document = document, document.exists {
                let sessionData = document.data()
                
                if sessionData!["createdBy"] as? String == userID {
                    sessionDocRef.updateData(["endTime" : Date()]) { updateError in
                        if let updateError = updateError {
                            completion(updateError)
                        }
                    }
                }
                
                let userDocRef = sessionDocRef.collection(self.memberColInSess).document(userID)
                userDocRef.getDocument { (document, error) in
                    if let error = error {
                        completion(error)
                    } else if let document = document, document.exists {
                        userDocRef.updateData(["endTime" : Date(),
                                               "activeSession" : false]) { updateError in
                            if let updateError = updateError {
                                completion(updateError)
                            } else {
                                completion(nil)
                            }
                        }
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
    func pollGroupSession(userID: String, sessionID: String, completion: @escaping ([String: [String: Any]]?, Error?) -> Void) {
        let dispatchGroup = DispatchGroup() // Create a Dispatch Group

        var dictOfMembers: [String: [String: Any]] = [:]
        
        let sessionDoc = db.collection(sessionCollection).document(sessionID)
        
        sessionDoc.getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
            } else if let document = document, document.exists {
                let sessionData = document.data()
                dictOfMembers["SESSIONVALUES"] = [:]
                
                if let endTimeTimestamp = sessionData!["endTime"] as? Timestamp {
                    dictOfMembers["SESSIONVALUES"]!["endTime"] = endTimeTimestamp.dateValue()
                }
                
                if let sessionName = sessionData!["sessionName"] as? String {
                    dictOfMembers["SESSIONVALUES"]!["sessionName"] = sessionName
                }
            }
        }

        let sessionDocRef = sessionDoc.collection(memberColInSess)

        sessionDocRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                for document in querySnapshot!.documents {
                    let memberDoc = document.data()
                    let memberID = document.documentID
                
                    
                    let sessionShareBool = memberDoc["shareSession"] as? Bool
                    if sessionShareBool == true {
                        // Update Users Location For All Users
                        dispatchGroup.enter()
                        self.updateLastLocation(sessionID: sessionID,
                                                userID: memberID)
                        dispatchGroup.leave()
                        if memberID == userID {
                            continue
                        }
                        dictOfMembers[memberID] = [:]

                    } else {
                        continue
                    }
                    
                    

                    
                    if let lastKnownLoc = memberDoc["lastLocation"] as? GeoPoint {
                        let lastKnownLocDict = ["latitude": lastKnownLoc.latitude,
                                                "longitude": lastKnownLoc.longitude]
                        dictOfMembers[memberID]?["Last Known Location"] = lastKnownLocDict
                    }

                    if let activeSession = memberDoc["activeSession"] as? Bool {
                        dictOfMembers[memberID]?["Still Active?"] = activeSession.description
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
                    
                    if !drinksInSession.isEmpty {
                        if let mostRecentDrink = drinksInSession.max(by: { $0.timeAt < $1.timeAt }) {
                            // `mostRecentDrink` now contains the `DrinkInfo` with the most recent timestamp
                            dictOfMembers[memberID]?["BAC"] = mostRecentDrink.getBAC()
                        } else {
                            // The `drinksInSession` array is empty
                            dictOfMembers[memberID]?["BAC"] = "0.00"
                        }
                    } else {
                        dictOfMembers[memberID]?["BAC"] = "0.00"
                    }


                    // Enter the Dispatch Group before calling self.getUserData
                    dispatchGroup.enter()

                    self.getUserData(userID: memberID) { (profileInfo, someError) in
                        if someError != nil {
                            // Handle error
                        } else if let tempProfile = profileInfo {
                            dictOfMembers[memberID]?["Contact Info"] = tempProfile.phoneNumber
                            dictOfMembers[memberID]?["name"] = tempProfile.firstName + " " + tempProfile.lastName
                            dictOfMembers[memberID]?["Profile Pic"] = tempProfile.profileImageURL
                        } else {
                            // Handle the case where profileInfo is nil
                        }
                        // Leave the Dispatch Group when self.getUserData is complete
                        dispatchGroup.leave()
                    }
                }
                
                // Notify the completion block when all tasks are complete
                dispatchGroup.notify(queue: .main) {
                    completion(dictOfMembers, nil)
                }
            }
        }
    }
    
    func getSessionInfo(userID: String, sessionDocumentID: String, completion: @escaping (SessionInfo?, Error?) -> Void){
        let sessionDBRef = db.collection(sessionCollection)
        let sessionRef = sessionDBRef.document(sessionDocumentID)
        
        sessionRef.getDocument { (sessionDocument, sessionError) in
            if let sessionError = sessionError {
                completion(nil, sessionError)
                return
            }
            
            if let sessionDocument = sessionDocument, sessionDocument.exists,
               let sessionData = sessionDocument.data() {
                self.sessionParser(userID: userID,
                                   sessionID: sessionDocumentID,
                                   sessionData: sessionData) { sessionTemp in
                    completion(sessionTemp, nil) // Return the sessionTemp object upon completion
                }
                
            } else {
                completion(nil, NSError(domain: "", code: 0, userInfo: ["message": "Session data not found or is invalid: \(sessionDocumentID)"]))
            }
        }
    }
    
    func validateSession(sessionID: String, completion: @escaping (Bool, Error?) -> Void) {
        let sessionDocRef = db.collection(sessionCollection).document(sessionID)

        sessionDocRef.getDocument { (document, error) in
            if let error = error {
                completion(false, error)
            } else if let document = document, document.exists {
                let sessionData = document.data()

                // Check if the sessionID exists within the collection
                guard let _ = sessionData else {
                    completion(false, nil)
                    return
                }

                // Check if sessionType is set to "Group"
                guard let sessionType = sessionData?["sessionType"] as? String, sessionType == "Group" else {
                    completion(false, nil)
                    return
                }

                // Check if endTime is after the current time
                if let endTimeTimestamp = sessionData?["endTime"] as? Timestamp,
                   endTimeTimestamp.dateValue() > Date() {
                    completion(true, nil)
                } else {
                    completion(false, nil)
                }
            } else {
                // Handle the case where the session document doesn't exist
                let notFoundError = NSError(domain: "Document Not Found", code: 404, userInfo: nil)
                completion(false, notFoundError)
            }
        }
    }

    func updateLastLocation(sessionID: String, userID: String) {
            guard CLLocationManager.locationServicesEnabled() else {
                print("Location services are not enabled.")
                return
            }

        let authorizationStatus = Self.location.authorizationStatus

            guard authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse else {
                print("Location access is not authorized.")
                // Handle not authorized case (e.g., prompt the user to enable location services)
                return
            }

            guard let currentLocation = Self.location.location else {
                print("Unable to get current location.")
                return
            }

            let userDocRef = db.collection(sessionCollection)
                .document(sessionID)
                .collection(memberColInSess)
                .document(userID)

        let locationData = GeoPoint(latitude: currentLocation.coordinate.latitude,
                                    longitude: currentLocation.coordinate.longitude)

            userDocRef.setData(["lastLocation": locationData], merge: true) { error in
                if let error = error {
                    print("Error updating last location: \(error.localizedDescription)")
                } else {
                    print("Last location updated successfully.")
                }
            }
        }
    
    /* ------------     Polls      ------------*/
    
    // Create a poll. Return poll ID on sucess. Otherwise error.
    func createPoll(userID: String, prompt: String, options: [String: Int], multipleVotes: Bool, votersAddOptions: Bool, expiration: Date, voters: [String], completion: @escaping (String?, Error?) -> Void) {
        let pollsCollectionRef = db.collection("polls")
        
        let pollData: [String: Any] = [
            "prompt": prompt,
            "options": options,
            "multipleVotes": multipleVotes,
            "votersAddOptions": votersAddOptions,
            "expiration": Timestamp(date: expiration),
            "createdBy": userID,
            "voters": voters
        ]
        
        var addedDocumentRef: DocumentReference?
        
        addedDocumentRef = pollsCollectionRef.addDocument(data: pollData) { error in
            if let error = error {
                completion(nil, error)
            } else {
                if let documentID = addedDocumentRef?.documentID {
                    completion(documentID, nil)
                } else {
                    completion(nil, NSError(domain: "", code: 0, userInfo: ["message": "Document ID not found"]))
                }
            }
        }
    }
    
    // Get a poll by ID. Returns a Poll object or error
    func getPoll(pollID: String, completion: @escaping (Poll?, Error?) -> Void) {
        let pollRef = db.collection("polls").document(pollID)
        
        pollRef.getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
            } else if let document = document, document.exists {
                if let poll = Poll(document: document) {
                    completion(poll, nil)
                } else {
                    completion(nil, NSError(domain: "", code: 0, userInfo: ["message": "Poll data not found or is invalid"]))
                }
            } else {
                completion(nil, NSError(domain: "", code: 0, userInfo: ["message": "Poll document not found"]))
            }
        }
    }
    
    // Retrieve all the polls given a list of poll IDs.
    func getPolls(pollIDs: [String], completion: @escaping ([Poll]?, Error?) -> Void) {
        let pollsCollectionRef = db.collection("polls")
        
        var polls: [Poll] = []
        var errors: [Error] = []
        let dispatchGroup = DispatchGroup()
        
        for pollID in pollIDs {
            let pollRef = pollsCollectionRef.document(pollID)
            dispatchGroup.enter()
            
            pollRef.getDocument { (document, error) in
                if let error = error {
                    errors.append(error)
                } else if let document = document, document.exists {
                    if let poll = Poll(document: document) {
                        polls.append(poll)
                    } else {
                        errors.append(NSError(domain: "", code: 0, userInfo: ["message": "Poll data not found or is invalid"]))
                    }
                }
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if errors.isEmpty {
                completion(polls, nil)
            } else {
                let compositeError = NSError(domain: "Poll Retrieval Error", code: 0, userInfo: ["errors": errors])
                completion(nil, compositeError)
            }
        }
    }
    
    func updatePoll(pollID: String, updatedData: [String: Any], completion: @escaping (Error?) -> Void) {
        let pollRef = db.collection("polls").document(pollID)
        
        // Update the poll document in Firestore
        pollRef.updateData(updatedData) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func updateVotes(pollID: String, votes: [String], completion: @escaping (Error?) -> Void) {
        let pollRef = db.collection("polls").document(pollID)
        var updateData: [String: Any] = [:]

        for vote in votes {
            updateData["options.\(vote)"] = FieldValue.increment(Int64(1))
        }

        pollRef.updateData(updateData) { error in
            if let error = error {
                print("FirestoreManager: Error updating vote: \(error.localizedDescription)")
            } else {
                print("FirestoreManger: Votes updated successfully.")
                completion(nil)
            }
        }
    }
    
    func updateVote(pollID: String, vote: String, completion: @escaping (Error?) -> Void) {
        let pollRef = db.collection("polls").document(pollID)
        let updateData = ["options.\(vote)": FieldValue.increment(Int64(1))]

        pollRef.updateData(updateData) { error in
            if let error = error {
                print("Error updating vote: \(error.localizedDescription)")
            } else {
                print("Vote updated successfully.")
                completion(nil)
            }
        }
    }
    
    func updateVoters(pollID: String, voter: String, completion: @escaping (Error?) -> Void) {
        let pollRef = db.collection("polls").document(pollID)
        let updateData = ["voters": FieldValue.arrayUnion([voter])]

        pollRef.updateData(updateData) { error in
            if let error = error {
                print("Error updating voters: \(error.localizedDescription)")
            } else {
                print("Voters updated successfully.")
                completion(nil)
            }
        }
    }

    func deletePoll(pollID: String, completion: @escaping (Error?) -> Void) {
        let pollRef = db.collection("polls").document(pollID)
        
        // Delete the poll document from Firestore
        pollRef.delete { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }


    func sessionParser(userID: String, sessionID: String, sessionData: [String: Any], completion: @escaping (SessionInfo) -> Void) {
        let sessionTemp = SessionInfo()
        sessionTemp.sessionDocID = sessionID
        
        if let createdBy = sessionData["createdBy"] as? String {
            sessionTemp.createdBy = createdBy
        }
        
        if let endTimeTimestamp = sessionData["endTime"] as? Timestamp {
            sessionTemp.endGroupSessionTime = endTimeTimestamp.dateValue()
        }
        
        if let sessionName = sessionData["sessionName"] as? String {
            sessionTemp.sessionName = sessionName
        }
        
        if let sessionType = sessionData["sessionType"] as? String {
            sessionTemp.sessionType = sessionType
        }
        
        if let polls = sessionData["polls"] as? [String] {
            sessionTemp.polls = polls
        }
        
        var membersList = [String]()
        let membersCollection = db.collection(sessionCollection).document(sessionID).collection(self.memberColInSess)
        membersCollection.getDocuments { (memberDocuments, memberError) in
            if memberError != nil {
                // Handle the error if needed
                print("Unable to parse session data: \(userID), \(sessionID)")
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
                    
                    if let endLocationGeoPoint = memberDoc["endLocation"] as? GeoPoint {
                        let endLocation = ["latitude": endLocationGeoPoint.latitude, 
                                           "longitude": endLocationGeoPoint.longitude]
                        sessionTemp.endLocation = endLocation
                    }
                    
                    if let startLocationGeoPoint = memberDoc["startLocation"] as? GeoPoint {
                        let startLocation = ["latitude": startLocationGeoPoint.latitude, "longitude": startLocationGeoPoint.longitude]
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
                    if let symptomsList = memberDoc["symptomsList"] as? [String] {
                        currentSymptoms.append(contentsOf: symptomsList)
                    }
                    
                    sessionTemp.symptomsList = currentSymptoms
                    sessionTemp.drinksInSession = drinksInSession
                }
                membersList.append(memberID)
            }
            sessionTemp.membersList = membersList
            
            // Call the completion handler when all data is collected
            completion(sessionTemp)
        }
    }
    
}


