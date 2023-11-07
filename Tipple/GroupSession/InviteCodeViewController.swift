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
    
    var sessionName: String = ""
    var endDate: Date = Date()
    
    var groupQRCode: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inviteCodeImageView.image = groupQRCode
        
        self.sessionNameTextLabel.text = sessionName

        // Display current session name and end date/time
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let formattedDate = dateFormatter.string(from: endDate)
        self.sessionEndDateTimeLabel.text = formattedDate
    }
    
    //TODO: make QR image bigger when clicked on
}
