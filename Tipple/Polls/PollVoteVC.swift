//
//  PollVoteVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 11/6/23.
//

import UIKit
import FirebaseAuth

class PollVoteVC: UIViewController, UITableViewDataSource, UITableViewDelegate, PollsDelegateVC {
    
    var session: SessionInfo?
    var delegate: PollsDelegate?
    weak var poll: Poll?
    
    @IBOutlet weak var pollTitleLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let optionVoteCellIdentifier = "OptionVoteCell"
    
    var createdByUser: ProfileInfo?
    let firestoreManager = FirestoreManager.shared
    
    var selectedOptionIndex: Int?
    var options: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getCreatedByUser()
        pollTitleLabel.text = poll?.prompt
        createdByLabel.text = poll?.createdBy
        if let poll = poll {
            options = Array(poll.options.keys)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: optionVoteCellIdentifier, for: indexPath) as! VoteOptionCell
        let option = options[indexPath.row]
        cell.optionLabel.text = option
        
        // Check if this cell corresponds to the selected option
        cell.isSelectedOption = selectedOptionIndex == indexPath.row
        cell.accessoryType = cell.isSelectedOption ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the previously selected option if there was one
        if let previousSelectedIndex = selectedOptionIndex {
            let previousSelectedIndexPath = IndexPath(row: previousSelectedIndex, section: 0)
            if let previousSelectedCell = tableView.cellForRow(at: previousSelectedIndexPath) as? VoteOptionCell {
                previousSelectedCell.toggleSelection()
            }
        }
        
        // Select the new option
        if let cell = tableView.cellForRow(at: indexPath) as? VoteOptionCell {
            cell.toggleSelection()
            selectedOptionIndex = indexPath.row
        }
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
    
    @IBAction func submitVote(_ sender: Any) {
        if let selectedOptionIndex = selectedOptionIndex {
            let selectedOption = options[selectedOptionIndex]
            let user = Auth.auth().currentUser
            
            firestoreManager.updateVotes(pollID: poll!.pollID!, userID: user!.uid, votes: [selectedOption]) { (error) in
                if let error = error {
                    print("Error submitting vote: \(error)")
                } else {
                    print("Vote saved successfully")
                    
                    self.delegate?.didVote()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            // Display an error message to the user indicating they need to select an option.
            AlertUtils.showAlert(title: "Invalid vote", message: "Please select at least one option", viewController: self)
        }
    }
}
