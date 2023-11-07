//
//  SessionInfo.swift
//  Tipple
//
//  Created by Andrew White on 10/15/23.
//

import Foundation


class SessionInfo {
    // Necessary Information for a given session
    var createdBy:       String         // USERID REF on Firebase
    var sessionDocID:    String?        // Used to store Firebase docID in session collection
    var membersList:     [String]       // Collection of docs (id same as userID) on Firebase
    var sessionType:     String         // String on Firebase
    
    var startTime:       Date           // Partof Memberslist doc --> Timestamp on Firebase
    var drinksInSession: [DrinkInfo]    // Partof Memberslist doc --> Array of map objects on firebase
    var stillActive:     Bool           // Partof Memberslist doc --> Boolean on firebase
    
    // Optional Values for both Session Types
    var startLocation:  String?         // Partof MembersList doc --> String rn but Geolocation later
    var endLocation:    String?         // Partof MembersList doc --> String rn but Geolocation later
    var ateBefore:      Bool?           // Partof MembersList doc --> Boolean on firebase
    var symptomsList:   [String]?       // Partof MembersList doc --> Array of strings on firebase
    
    // Optional Group Session Fields
    var sessionName: String?            // String on firebase
    var shareSession: Bool?             // Bool on firebase
    var endGroupSessionTime: Date?      // Endtime on firebase
    var polls: [String]?
    
    init() {
        self.createdBy = ""
        self.sessionDocID = ""
        self.membersList = []
        self.sessionType = ""
        self.startTime = Date()
        self.drinksInSession = []
        self.stillActive = false
       
        self.startLocation = ""
        self.endLocation = ""
        self.ateBefore = false
        self.symptomsList = []
        
        self.sessionName = ""
        self.shareSession = false
        self.endGroupSessionTime = Date()
        self.polls = []
    }
    
    init (createdBy: String, sessionDocID: String? = nil, membersList: [String], sessionType: String, startTime: Date, drinksInSession: [DrinkInfo], stillActive: Bool,
        startLocation: String? = nil, endLocation: String? = nil, ateBefore: Bool? = nil, symptomsList: [String]? = nil,
          sessionName: String? = nil, shareSession: Bool? = nil, endGroupSessionTime: Date? = nil, polls: [String]? = nil) {
            self.createdBy = createdBy
            self.sessionDocID = sessionDocID
            self.membersList = membersList
            self.sessionType = sessionType
            self.startTime = startTime
            self.drinksInSession = drinksInSession
            self.stillActive = stillActive
            self.startLocation = startLocation
            self.endLocation = endLocation
            self.ateBefore = ateBefore
            self.symptomsList = symptomsList
            self.sessionName = sessionName
            self.shareSession = shareSession
            self.endGroupSessionTime = endGroupSessionTime
            self.polls = polls
    }
    
    func isSessionHost(userID: String) -> Bool {
        return self.createdBy.contains(userID)
    }
    
    func getSessionDocID() -> String {
        return self.sessionDocID ?? ""
    }
    
    func getSessionDrinks() -> [DrinkInfo] {
        return drinksInSession
    }
    
    func getAllSymptoms() -> [String] {
        return symptomsList ?? []
    }
    
    func getStartTime() -> Date {
        return startTime
    }
    
    func getName() -> String {
        return sessionName ?? ""
    }
    
    func getType() -> String {
        return sessionType
    }
    
    func getAlcConsumedInGrams() -> Float {
        var totalAlcoholGrams: Float = 0.0

        for drink in drinksInSession {
            totalAlcoholGrams += drink.getAlcInGrams()
        }

        return totalAlcoholGrams
    }
}
