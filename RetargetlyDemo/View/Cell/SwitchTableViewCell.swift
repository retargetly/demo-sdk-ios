//
//  SwitchTableViewCell.swift
//  RetargetlyDemo
//
//  Created by José Valderrama on 12/01/2021.
//  Copyright © 2021 Retargetly. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchControl: UISwitch!
    
    func configure(title: String?, on: Bool) {
        titleLabel.text = title
        switchControl.setOn(on, animated: false)
    }
    
}
