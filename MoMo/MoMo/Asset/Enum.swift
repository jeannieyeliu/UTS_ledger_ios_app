//
//  Enum.swift
//  MoMo
//
//  Created by BonnieLee on 25/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import Foundation
import UIKit

class Enum {
    
    enum StringList: String {
        //General
        case blank = ""
        case dollar = "$ &d"
        
        //HomeViewController
        case recordList = "Record List"
        case toPayList = "To Pay List"
        case dafaultImg = "icons8-rating-64"
        
        //Navigation
        case addRecord = "addRecordNav"
        case showStat = "showStatisticNav"
        case editExpense = "editExpenseNav"
        case addToPay = "addToPayNav"
        
        //Firebase
        case root = "MoMo"
        case date = "Date"
        
        //Record Model
        case amount = "amount"
        case category = "category"
        case note = "note"
        
        //Cell
        case calendar = "calendarCell"
        case footer = "footerCell"
        case expense = "expenseCell"
        case toPay = "toPayCell"
        
        //Format
        case dateFormat1 = "MMM yy"
        
        //UIFont
        case chalkFont = "Chalkboard SE"
    }
}
