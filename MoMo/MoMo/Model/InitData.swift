//
//  InitData.swift
//  MoMo
//
//  Created by BonnieLee on 22/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import Foundation
import FirebaseDatabase

class InitData {
    var refDate: DatabaseReference!
    var dateKey = String()
    var noOfEvent = Int()
    var eventArray = [[String]]()
    
    func getEventNumber() -> [[String]] {
        eventArray = [[String]]()
        var eventInfoArray = [String]()
        refDate = Database.database().reference().child("MoMo").child("Date")
        refDate.observe(.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for event in snapshot.children.allObjects as! [DataSnapshot] {
                    eventInfoArray = [String]()
                    self.dateKey = event.key
                    self.noOfEvent = event.children.allObjects.count
                    eventInfoArray.append(self.dateKey)
                    eventInfoArray.append("\(self.noOfEvent)")
                    self.eventArray.append(eventInfoArray)
                }
            }
        })
        return eventArray
    }
}
