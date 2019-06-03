//
//  ExpenseTableViewCell.swift
//  MoMo
//
//  Created by BonnieLee on 17/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import UIKit

// This class is to show the expense cell view
class ExpenseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lb_amount: UILabel!
    @IBOutlet weak var lb_note: UILabel!
    @IBOutlet weak var lb_countDown: UILabel!
    @IBOutlet weak var lb_dayLeft: UILabel!
    @IBOutlet weak var iv_category: UIImageView!
    
    let warningDate = 3
    
    // This function is to set the color of the labels accordingly
    // (e.g. < warningDate -> red, > warningDate -> blue)
    func setColor(day: Int) {
        if day <= warningDate {
            lb_dayLeft.textColor = UIColor.red
            lb_countDown.backgroundColor = UIColor.red
        } else {
            lb_dayLeft.textColor = lb_amount.textColor
            lb_countDown.backgroundColor = lb_amount.textColor
        }
    }
}
