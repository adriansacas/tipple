//
//  InviteCodeViewController.swift
//  Tipple
//
//  Created by Danica Padlan on 10/26/23.
//

import UIKit

class InviteCodeVC: UIViewController {

    @IBOutlet weak var sessionNameTextLabel: UILabel!
    @IBOutlet weak var sessionEndDateTimeLabel: UILabel!
    @IBOutlet weak var inviteCodeImageView: UIImageView!
    
    var currentSession: SessionInfo?
    var groupQRCode: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Display current session name and end date/time
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let formattedDate = dateFormatter.string(from: currentSession!.endGroupSessionTime)
        
        sessionNameTextLabel.text = currentSession?.sessionName
        sessionEndDateTimeLabel.text = formattedDate
        
        inviteCodeImageView.image = groupQRCode
    }
    
    //TODO: make QR image bigger when clicked on?
    
}
