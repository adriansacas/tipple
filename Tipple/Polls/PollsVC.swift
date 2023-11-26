//
//  PollsVC.swift
//  Tipple
//
//  Created by Adrian Sanchez on 11/5/23.
//

import UIKit
import FirebaseAuth

protocol PollsDelegate: AnyObject {
    func didCreateNewPoll(_ newPoll: Poll)
    func didVote()
}

protocol PollsDelegateVC: UIViewController {
    var session: SessionInfo? { get set }
    var delegate: PollsDelegate? { get set }
}

class PollsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, PollsDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let pollCellIdentifier = "PollCell"
    let pollDetailsSegueIdentifier = "PollDetailsSegueIdentifier"
    let createPollSegueIdentifier = "CreatePollSegueIdentifier"
    let pollResultsSegueIdentifier = "PollResultsSegueIdentifier"
    let firestoreManager = FirestoreManager.shared
    var polls: [Poll] = []
//    TODO: change to sessionID, get the session info, pass the session id from the parent view
    var sessionID: String?
    var session: SessionInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //TODO: Comment out after testing
        sessionID = "7cuNiTanSGvGqkfXVpBe"

        getSession()
    }
    
    func didCreateNewPoll(_ newPoll: Poll) {
        getPolls()
    }
    
    func didVote() {
        getPolls()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return polls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure each cell in the table view.
        let cell = tableView.dequeueReusableCell(withIdentifier: pollCellIdentifier, for: indexPath as IndexPath) as! PollCell
        
        let row = indexPath.row
        let poll = polls[row]
        cell.pollLabel.text = poll.prompt
        
        return cell
    }
    
    // Swipe delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let pollToDelete = polls[indexPath.row]
            if let pollIDToDelete = pollToDelete.pollID {
                if let currentUserUID = Auth.auth().currentUser?.uid, currentUserUID == pollToDelete.createdBy {
                    firestoreManager.deletePoll(pollID: pollIDToDelete) { error in
                        if let error = error {
                            print("Error deleting poll: \(error)")
                        } else {
                            // Poll deleted successfully
                            self.polls.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                            // TODO: do better checks for nil. Also consider keeping a list of ids handy
                            self.session!.polls = self.polls.map{ $0.pollID! }
                            let fields = ["polls": self.session?.polls as Any] as [String : Any]
                            // TODO: Consider using FieldValue.arrayUnion(valuesToAdd) instead of passing all the current pollIDs
                            self.firestoreManager.updateGroupSession(userID: currentUserUID, sessionID: self.sessionID!, fields: fields) { error in
                                if let error = error {
                                    print("Error updating group session: \(error.localizedDescription)")
                                } else {
                                    print("Group session updated successfully.")
                                }
                            }
                        }
                    }
                } else {
                    AlertUtils.showAlert(title: "Cannot Delete", message: "Only the author can delete this poll.", viewController: self)
                    print("Unauthorized to delete this poll. Current user's UID does not match createdBy.")
                }
            } else {
                print("Error retrieving poll ID")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let poll = polls[indexPath.row]
        let user = Auth.auth().currentUser
        
        if poll.voters.contains(user!.uid) { // has voted. show results
            performSegue(withIdentifier: pollResultsSegueIdentifier, sender: self)
        } else {
            performSegue(withIdentifier: pollDetailsSegueIdentifier, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == pollDetailsSegueIdentifier {
            if let pollVoteVC = segue.destination as? PollVoteVC,
               let pollIndex = tableView.indexPathForSelectedRow?.row {
                pollVoteVC.pollID = polls[pollIndex].pollID
                pollVoteVC.delegate = self
            }
        } else if segue.identifier == createPollSegueIdentifier {
            if let createPollVC = segue.destination as? CreatePollVC {
                createPollVC.delegate = self
                createPollVC.session = self.session
            }
        } else if segue.identifier == pollResultsSegueIdentifier {
            if let pollResultsVC = segue.destination as? PollResultsVC,
                let pollIndex = tableView.indexPathForSelectedRow?.row {
                    pollResultsVC.pollID = polls[pollIndex].pollID
            }
        }
    }
    
    func getSession() {
        guard let sessionID = sessionID else {
            return
        }
        let user = Auth.auth().currentUser
        
        firestoreManager.getSessionInfo(userID: user!.uid, sessionDocumentID: sessionID) { sessionInfo, error in
            if let error = error {
                print("Error fetching session information: \(error.localizedDescription)")
            } else if let sessionInfo = sessionInfo {
                self.session = sessionInfo
                self.getPolls()
            }
        }
    }
    
    func getPolls() {
        guard let session = session,
              let pollsIDs = session.polls else {
            return
        }
        
        firestoreManager.getPolls(pollIDs: pollsIDs) { [weak self] (polls, error) in
            if let error = error {
                print("Error fetching polls: \(error)")
            } else if let polls = polls {
                // Update the polls array and refresh the table view
                self?.polls = polls.sorted { $0.prompt < $1.prompt }
                self?.tableView.reloadData()
//                DispatchQueue.main.async {
//                    self?.tableView.reloadData()
//                }
            }
        }
    }
}
