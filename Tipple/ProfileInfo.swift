//
//  ProfileInfo.swift
//  Tipple
//
//  Created by Adrian Sanchez on 10/14/23.
//

import Foundation

class ProfileInfo {
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var birthDay: Date
    var gender: String
    var heightFeet: Int
    var heightInches: Int
    var weight: Int

    init(firstName: String, lastName: String, phoneNumber: String, birthDay: Date, gender: String, heightFeet: Int, heightInches: Int, weight: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.birthDay = birthDay
        self.gender = gender
        self.heightFeet = heightFeet
        self.heightInches = heightInches
        self.weight = weight
    }

    // Function to return the full name (first name and last name)
    func getName() -> String {
        return "\(firstName) \(lastName)"
    }

    // Function to return the height as a single string (feet and inches)
    func getHeight() -> String {
        return "\(heightFeet)' \(heightInches)\""
    }
    
    // Function to return the weight
    func getWeight() -> String {
        return "\(weight)lbs"
    }

    // Function to return the phone number in a hyphenated format
    func getPhoneNumber() -> String {
        let areaCode = phoneNumber.prefix(3)
        let firstPart = phoneNumber.dropFirst(3).prefix(3)
        let lastPart = phoneNumber.dropFirst(6)
        return "\(areaCode)-\(firstPart)-\(lastPart)"
    }
    
    // Function to return a formated birth date
    func getBirthDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: birthDay)
    }
}
