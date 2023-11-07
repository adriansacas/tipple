//
//  VoteOptionCell.swift
//  Tipple
//
//  Created by Adrian Sanchez on 11/7/23.
//

import UIKit

class VoteOptionCell: UITableViewCell {
    @IBOutlet weak var optionLabel: UILabel!
    var isSelectedOption: Bool = false
        
    func toggleSelection() {
        isSelectedOption.toggle()
        accessoryType = isSelectedOption ? .checkmark : .none
    }
}
