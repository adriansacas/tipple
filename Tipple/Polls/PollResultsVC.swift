//
//  PollResultsVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 11/7/23.
//

import UIKit

class PollResultsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var pollTitleLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalVotesLabel: UILabel!
    let optionResultCellIdentifier = "OptionResultCell"
    
    var poll: Poll?
    var optionsWithVoteCounts: [(String, Int)] = []  // Array to store options with vote counts
    
    var createdByUser: ProfileInfo?
    let firestoreManager = FirestoreManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        if let poll = poll {
            getCreatedByUser()
            pollTitleLabel.text = poll.prompt
            
            // Prepare the options with vote counts
            optionsWithVoteCounts = poll.options.map { ($0.key, $0.value) }

            // Sort the options by vote count (you can change the sorting order as needed)
            optionsWithVoteCounts.sort { $0.1 > $1.1 }
            
            var totalVotes = 0

            for (_, voteCount) in optionsWithVoteCounts {
                totalVotes += voteCount
            }
            
            totalVotesLabel.text = "Total votes: \(totalVotes)"

            // Reload the table view to display the data
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsWithVoteCounts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: optionResultCellIdentifier, for: indexPath) as! ResultOptionCell
        let optionWithVoteCount = optionsWithVoteCounts[indexPath.row]
        cell.optionLabel.text = optionWithVoteCount.0  // Option
        cell.countLabel.text = "\(optionWithVoteCount.1)"  // Vote count
        return cell
    }
    
    func getCreatedByUser() {
        guard poll != nil,
        let userID = poll?.createdBy else {
            return
        }
        
        firestoreManager.getUserData(userID: userID) {
            [weak self] (profileInfo, error) in
            if let error = error {
                print("Error fetching user: \(error)")
            } else if let profileInfo = profileInfo {
                self?.createdByUser = profileInfo
                self?.createdByLabel.text = "Asked by \(self?.createdByUser?.firstName ?? "")"
            }
        }
    }
}

