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
    
    let firestoreManager = FirestoreManager.shared
    var session: SessionInfo?
    var delegate: PollsDelegate?
    var poll: Poll?
    var pollID: String?
    
    @IBOutlet weak var pollTitleLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let optionVoteCellIdentifier = "OptionVoteCell"
    let addOptionCellIdentifier = "AddOptionCell"
    
    var createdByUser: ProfileInfo?
    var currentUser: User?
    
    var selectedOptionsIndex = Set<Int>()
    var options: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pollTitleLabel.numberOfLines = 0
        pollTitleLabel.lineBreakMode = .byWordWrapping
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getCurrentUser()
        getPoll()
    }
    
    func getCurrentUser() {
        AuthenticationManager.shared.getCurrentUser(viewController: self) { user, error in
            if let error = error {
                // Errors are handled in AuthenticationManager
                print("Error retrieving user: \(error.localizedDescription)")
            } else if let user = user {
                // Successfully retrieved the currentUser
                self.currentUser = user
                // Do anything that needs the currentUser
            } else {
                // No error and no user. Handled in AuthenticationManager
                print("No user found and no error occurred.")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = options[indexPath.row]
        
        // Add option cell
        if option == addOptionCellIdentifier {
            let cell = tableView.dequeueReusableCell(withIdentifier: addOptionCellIdentifier, for: indexPath)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: optionVoteCellIdentifier, for: indexPath) as! VoteOptionCell
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
        
        // Insert a new OptionCell when the AddOptionCell is tapped
        if indexPath.row == options.count - 1 && poll.votersAddOptions {
            showAddOptionPopUp()
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
    
    // Insert a new OptionCell in the second to last position
    func insertNewOptionCell(option: String) {
        // Create a new option cell and add it to the second-to-last position\
        options.insert(option, at: options.count - 1)

        // Insert the cell in the table view
        let newCellIndexPath = IndexPath(row: options.count - 2, section: 0)
        tableView.insertRows(at: [newCellIndexPath], with: .automatic)
    }
    
    func showAddOptionPopUp() {
        let controller = UIAlertController(
            title: "Add New Option",
            message: nil,
            preferredStyle: .alert
        )
        
        // Add a text field to the alert
        controller.addTextField { textField in
            textField.placeholder = "Option"
        }

        // The "OK" action
        let saveAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            // Retrieve the first text field in the alert
            if let textField = controller.textFields?.first,
               let text = textField.text, !text.isEmpty {
                // Insert the new option cell
                self?.insertNewOptionCell(option: text)
            }
        }
        saveAction.setValue(UIColor.okay, forKey:"titleTextColor")

        // The "Cancel" action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.cancel, forKey:"titleTextColor")

        // Add actions to the alert controller
        controller.addAction(saveAction)
        controller.addAction(cancelAction)

        // Present the alert
        self.present(controller, animated: true)
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
        
        guard let currentUser = currentUser,
              let poll = poll,
              let pollID = poll.pollID else {
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
                
                self.firestoreManager.updateVoters(pollID: pollID, voter: currentUser.uid) { (error) in
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
        
        getCreatedByUser()
        
        pollTitleLabel.text = poll.prompt
        
        options = Array(poll.options.keys)
        if poll.votersAddOptions {
            options.append(addOptionCellIdentifier)
        }
        // Reload the table view to display the data
        tableView.reloadData()
    }
}
