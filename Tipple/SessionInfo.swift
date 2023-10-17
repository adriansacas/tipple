//
//  SessionInfo.swift
//  Tipple
//
//  Created by Andrew White on 10/15/23.
//

import Foundation


class SessionInfo {
    // Necessary Information for a given session
    var startTime: Date
    var sessionType: String
    var drinksInSession: [DrinkInfo]
    
    // Optional Values for both Session Types
    var startLocation: String?
    var endLocation: String?
    var ateBefore: Bool?
    
    // Optional Group Session Fields
    var sessionName: String?
    var shareSession: Bool?
    var membersList: [String]?
    // var polls: [PollInfo]?
    
    init() {
        self.startTime = Date()
        self.sessionType = ""
        self.drinksInSession = []
        self.startLocation = ""
        self.endLocation = ""
        self.ateBefore = false
        self.sessionName = ""
        self.shareSession = false
        self.membersList = []
    }
    
    init(startTime: Date, sessionType: String, drinksInSession: [DrinkInfo], startLocation: String? = nil, endLocation: String? = nil, ateBefore: Bool? = nil, sessionName: String? = nil, shareSession: Bool? = nil, membersList: [String]? = nil) {
        self.startTime = startTime
        self.sessionType = sessionType
        self.drinksInSession = drinksInSession
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.ateBefore = ateBefore
        self.sessionName = sessionName
        self.shareSession = shareSession
        self.membersList = membersList
    }
    
    
    func getSessionDrinks() -> [DrinkInfo] {
        return drinksInSession
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
