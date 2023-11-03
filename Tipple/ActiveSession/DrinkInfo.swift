//
//  DrinkInfo.swift
//  Tipple
//
//  Created by Andrew White on 10/15/23.
//

import Foundation


class DrinkInfo {
    var type: String
    var timeAt: Date
    var drinkNum: Int
    var bacAtTime: Float
    
    init(drinkType: String, drinkNumIn: Int, bacAtTime: Float){
        self.type = drinkType
        self.timeAt = Date.now
        self.drinkNum = drinkNumIn
        self.bacAtTime = bacAtTime
    }
    
    init(drinkType: String, drinkNum: Int, bacAtTime: Float, timeAt: Date) {
        self.type = drinkType
        self.timeAt = timeAt
        self.drinkNum = drinkNum
        self.bacAtTime = bacAtTime
    }
    
    // Returns timestamp of drink in "hr: min am/pm"
    func getTimestamp() -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        
        return timeFormatter.string(from: self.timeAt)
    }
    
    // Returns the drink type with the first letter capitalized
    func getType() -> String {
        return self.type.capitalized
    }
    
    // Returns the BAC level at the time of drink creation
    func getBAC() -> String {
        return String(format: "%.2f", self.bacAtTime)
    }
    
    // Returns the amount of grams in a given alc type
    func getAlcInGrams() -> Float {
        switch self.type {
            case "beer": return 13.0
            case "seltzer": return 9.0
            case "shot": return 14.0
            case "wine": return 16.0
            case "cocktail": return 14.0
            default: return 14.0
        }
    }
}
