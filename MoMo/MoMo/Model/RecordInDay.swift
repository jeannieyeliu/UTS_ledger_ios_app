//
//  RecordInDay.swift
//  MoMo
//
//  Created by BonnieLee on 17/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import Foundation

class Record {
    var id = Int()
    var amount: Double = 0.0
    var note: String = "Note number: "
    var category = String()
    
    init(id: Int, amount: Double, note: String){
        self.id = id
        self.amount = amount
        self.note = note
    }
}
