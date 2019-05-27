//
//  Category.swift
//  MoMo
//
//  Created by BonnieLee on 22/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import Foundation

class Category {
    var id = String()
    var description = String()
    var image = String()
    
    init(id: String, description: String, image: String) {
        self.id = id
        self.description = description
        self.image = image
    }
}
