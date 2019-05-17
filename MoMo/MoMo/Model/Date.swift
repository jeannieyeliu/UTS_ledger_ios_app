//
//  RecordDate.swift
//  MoMo
//
//  Created by BonnieLee on 17/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import Foundation

class RecordDate {
    var date = String()
    var records = [Record]()
    
    init(date: String, records: [Record]) {
        self.date = date
        self.records = records
    }
    
    func getTotalAmount(recordArray: [Record]) -> Double {
        var totalAmount = [Double]()
        for record in recordArray {
            totalAmount.append(record.amount)
        }
        return totalAmount.reduce(0, +)
    }
}
