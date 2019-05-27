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
        case dollar = "$ "
        
        //HomeViewController
        case recordList = "Record List"
        case toPayList = "To Pay List"
        case dafaultImg = "icons8-rating-64"
        
        //StatisticViewController
        case overused = "Overused"
        case zeroDouble = "0.0"
        
        //Navigation
        case addRecord = "addRecordNav"
        case showStat = "showStatisticNav"
        case editExpense = "editExpenseNav"
        case addToPay = "addToPayNav"
        case recordHome = "recordToHomeNav"
        
        //Firebase
        case root = "MoMo"
        case date = "Date"
        case cate = "Category"
        case cateID = "/id"
        case cateDesc = "/recordTypeDesc"
        case cateImg = "/recordTypeImg"
        
        //Record Model
        case amount = "amount"
        case category = "category"
        case note = "note"
        
        //Cell
        case calendar = "calendarCell"
        case footer = "footerCell"
        case expense = "expenseCell"
        case toPay = "toPayCell"
        case categoryC = "categoryCell"
        
        //Alert
        case deleteTit = "Delete"
        case deleteMes = "Do you want to delete this record?"
        case yes = "Yes"
        case cancel = "Cancel"
        
        //Format
        case dateFormat1 = "MMM yy"
        case dateFormat2 = "yyyy-MM-dd"
        case dayFormat1 = "dd"
        case monthFormat1 = "L"
        case monthFormat2 = "LL"
        case yearFormat1 = "y"
        
        //UIFont
        case chalkFont = "Chalkboard SE"
        case chalkLight = "Chalkboard SE Light"
        case chalkBold = "Chalkboard SE Bold"
        
        //Default
        case budget = "budget"
        case isMonth = "isMonth"
    }
    
    enum GraphType {
        case week
        case month
    }
}
