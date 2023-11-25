//
//  PollVoteVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 11/6/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PollVoteVC: UIViewController, UITableViewDataSource, UITableViewDelegate, PollsDelegateVC {
    
    var session: SessionInfo?
    var delegate: PollsDelegate?
    var poll: Poll?
    var pollID: String?
    
    @IBOutlet weak var pollTitleLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let optionVoteCellIdentifier = "OptionVoteCell"
    
    var createdByUser: ProfileInfo?
    let firestoreManager = FirestoreManager.shared
    
    var selectedOptionsIndex = Set<Int>()
    var options: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getCreatedByUser()
        pollTitleLabel.text = poll?.prompt
        createdByLabel.text = poll?.createdBy
        
        getPoll()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: optionVoteCellIdentifier, for: indexPath) as! VoteOptionCell
        let option = options[indexPath.row]
        cell.optionLabel.text = option
        
        // Check if this cell corresponds to the selected option
        cell.isSelectedOption = selectedOptionsIndex.contains(indexPath.row)
        cell.accessoryType = cell.isSelectedOption ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let poll = poll, 
            let selectedCell = tableView.cellForRow(at: indexPath) as? VoteOptionCell else {
            print("Error: No poll or selected cell cant be processed.")
            return
        }
        
        // Deselect the selected row if it has been selected already.
        if selectedOptionsIndex.contains(indexPath.row) {
            selectedOptionsIndex.remove(indexPath.row)
            selectedCell.toggleSelection()
            return
        }
        
        if !poll.multipleVotes {
            // Deselect the previously selected row if there was one
            if let previousSelectedIndex = selectedOptionsIndex.first {
                let previousSelectedIndexPath = IndexPath(row: previousSelectedIndex, section: 0)
                if let previousSelectedCell = tableView.cellForRow(at: previousSelectedIndexPath) as? VoteOptionCell {
                    previousSelectedCell.toggleSelection()
                    selectedOptionsIndex.remove(previousSelectedIndex)
                }
            }
        }
        
        // Select the new row
        selectedCell.toggleSelection()
        selectedOptionsIndex.insert(indexPath.row)
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
        guard !selectedOptionsIndex.isEmpty else {
            // Display an alert or a message to inform the user to select an option
            AlertUtils.showAlert(title: "Invalid vote", message: "Please select at least one option", viewController: self)
            return
        }
        
        guard let poll = poll,
              let pollID = poll.pollID,
              let currentUserUID = Auth.auth().currentUser?.uid else {
            print("Error: no poll, pollID or currentUserUID")
            return
        }
        
        // Create a list of selected options based on the row index
        var selectedOptions: [String] = []

        for index in selectedOptionsIndex {
            if index < options.count {
                selectedOptions.append(options[index])
            } else {
                print("Index \(index) is out of bounds")
            }
        }
        
        // Register the votes in the database
        firestoreManager.updateVotes(pollID: pollID, votes: selectedOptions) { (error) in
            if let error = error {
                print("Error submitting vote: \(error)")
            } else {
                print("Vote saved successfully")
                
                self.firestoreManager.updateVoters(pollID: pollID, voter: currentUserUID) { (error) in
                    if let error = error {
                        print("Error submitting voters: \(error)")
                    } else {
                        print("Voters saved successfully")

                        self.delegate?.didVote()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    func getPoll() {
        guard let pollID = pollID else {
            return
        }
        
        firestoreManager.getPoll(pollID: pollID) { (poll, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let poll = poll {
                self.poll = poll
                self.continueAfterPollFetched()
            } else {
                print("No poll data and no error were returned.")
            }
        }
    }
    
    func continueAfterPollFetched() {
        guard let poll = poll else {
            return
        }
        
        options = Array(poll.options.keys)
        // Reload the table view to display the data
        tableView.reloadData()
    }
}
