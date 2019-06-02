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
    
    let warningDate = 3
    
    /*
     This function is to set the color of the labels accordingly.
     
     day: the range of countdown date that will change the event color to red.
     */
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
