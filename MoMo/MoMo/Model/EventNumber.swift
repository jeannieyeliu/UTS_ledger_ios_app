//
//  EventNumber.swift
//  MoMo
//
//  Created by BonnieLee on 22/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import Foundation

// This class is to store the event data
class Event {
    var date = String()
    var eventNumber = Int()
    
    init(date: String, eventNumber: Int) {
        self.date = date
        self.eventNumber = eventNumber
    }
}

