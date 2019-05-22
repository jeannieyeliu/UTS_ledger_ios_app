//
//  RecordInDay.swift
//  MoMo
//
//  Created by BonnieLee on 17/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import Foundation

class Record {
    var id = String()
    var amount: Double = 0.0
    var note: String = "Note number: "
    var category = String()
    
    init(id: String, amount: Double, category: String, note: String){
        self.id = id
        self.amount = amount
        self.note = note
        self.category = category
    }
    
    func getTotalAmount(recordArray: [Record]) -> Double {
        var totalAmount = [Double]()
        for record in recordArray {
            totalAmount.append(record.amount)
        }
        return totalAmount.reduce(0, +)
    }
}
