//
//  RecordInDay.swift
//  MoMo
//
//  Created by BonnieLee on 17/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import Foundation

// This class is to store the record data
class Record {
    var id = String()
    var amount: Double = 0.0
    var note: String = String()
    var category = String() // maybe this should be Category instance
    
    init(id: String, amount: Double, category: String, note: String){
        self.id = id
        self.amount = amount
        self.note = note
        self.category = category
    }
}

// This class is to store the record sum data
class RecordSum {
    var amount = Double()
    
    init (amount: Double) {
        self.amount = amount
    }
}
