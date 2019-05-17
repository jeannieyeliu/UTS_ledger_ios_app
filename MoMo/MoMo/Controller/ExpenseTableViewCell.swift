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
    @IBOutlet weak var iv_category: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
