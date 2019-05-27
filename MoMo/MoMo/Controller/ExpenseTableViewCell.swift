//
//  ExpenseTableViewCell.swift
//  MoMo
//
//  Created by BonnieLee on 17/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {

    @IBOutlet weak var lb_amount: UILabel!
    @IBOutlet weak var lb_note: UILabel!
    @IBOutlet weak var lb_countDown: UILabel!
    @IBOutlet weak var lb_dayLeft: UILabel!
    @IBOutlet weak var iv_category: UIImageView!

    func setColor(day: Int) {
        if day <= 3 {
            lb_dayLeft.textColor = UIColor.red
            lb_countDown.backgroundColor = UIColor.red
        } else {
            lb_dayLeft.textColor = lb_amount.textColor
            lb_countDown.backgroundColor = lb_amount.textColor
        }
    }
    
    func getEventColor(day: Int) -> UIColor {
        if day <= 3 {
            return UIColor.red
        } else {
            return UIColor(red:0.00, green:0.50, blue:0.76, alpha:1.0)
        }
    }
}
