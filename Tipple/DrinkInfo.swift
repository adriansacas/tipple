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
        return String(format: "Angle: %.2f", self.bacAtTime)
    }
}
