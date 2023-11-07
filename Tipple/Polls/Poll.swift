//
//  Poll.swift
//  Tipple
//
//  Created by Adrian Sanchez on 11/5/23.
//

import UIKit
import FirebaseFirestore

class Poll {
    var pollID: String?
    var prompt: String
    var options: [String: Int]
    var multipleVotes: Bool
    var votersAddOptions: Bool
    var expiration: Date
    var createdBy: String
    var voters: Set<String>

    init(prompt: String, options: [String: Int], multipleVotes: Bool, votersAddOptions: Bool, expiration: Date, createdBy: String, voters: [String]) {
        self.prompt = prompt
        self.options = options
        self.multipleVotes = multipleVotes
        self.votersAddOptions = votersAddOptions
        self.expiration = expiration
        self.createdBy = createdBy
        self.voters = Set(voters)
    }
    
    // Additional initializer to create a Poll from a Firestore DocumentSnapshot
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let prompt = data["prompt"] as? String,
              let options = data["options"] as? [String: Int],
              let multipleVotes = data["multipleVotes"] as? Bool,
              let votersAddOptions = data["votersAddOptions"] as? Bool,
              let expirationTimestamp = data["expiration"] as? Timestamp,
              let createdBy = data["createdBy"] as? String,
              let voters = data["voters"] as? [String] else {
            return nil
        }

        self.pollID = document.documentID
        self.prompt = prompt
        self.options = options
        self.multipleVotes = multipleVotes
        self.votersAddOptions = votersAddOptions
        self.expiration = expirationTimestamp.dateValue()
        self.createdBy = createdBy
        self.voters = Set(voters)
    }
}
