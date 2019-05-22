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

    func getEventNumber() {
        refDate.observe(.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                for event in snapshot.children.allObjects as! [DataSnapshot] {
                    let dateKey = event.key
                    let noOfEvent = event.children.allObjects.count
                    print("Date: \(dateKey). \nAmount: \(noOfEvent)")
                }
            }
        })
    }
}
