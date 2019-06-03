//
//  Consts.swift
//  MoMo
//
//  Created by 刘烨 on 27/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import UIKit

// This class is to store all the constants to avoid hard coding
class Const {
    
    // Charts
    static let weekTitle = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    static let weekTitleMon = ["Mon"," Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    static let defaultChartType: Enum.GraphType = .week
    static let barLabel = "Expenses in last 7 days"
    static let lineLabel = "Expenses in last 30 days"
    static let topayLabel = "To Pay"
    static let limitLineLabel = "Daily Average: $"
    static let daysInAWeek = 7
    static let daysInAMonth = 30
    static let weekNumber = ["Sun":0, "Mon":1, "Tue":2, "Wed":3, "Thu":4, "Fri":5, "Sat":6]
    
    //General
    static let blank = ""
    static let dollar = "$ "
    static let newLine = "\n"
    
    // Number
    static let zero = 0
    static let datePrefix = 10
    
    //HomeViewController
    static let recordList = "Record List"
    static let toPayList = "To Pay List"
    static let dafaultImg = "icons8-rating-64"
    
    //StatisticViewController
    static let overused = "Overused"
    static let zeroDouble = "0.0"
    
    //Navigation
    static let addRecord = "addRecordNav"
    static let showStat = "showStatisticNav"
    static let editExpense = "editExpenseNav"
    static let addToPay = "addToPayNav"
    static let recordHome = "recordToHomeNav"
    
    //Firebase
    static let root = "MoMo"
    static let date = "Date"
    static let cate = "Category"
    static let cateID = "/id"
    static let cateDesc = "/recordTypeDesc"
    static let cateImg = "/recordTypeImg"
    
    //Record Model
    static let amount = "amount"
    static let category = "category"
    static let note = "note"
    
    //Cell
    static let calendar = "calendarCell"
    static let footer = "footerCell"
    static let expense = "expenseCell"
    static let toPay = "toPayCell"
    static let categoryC = "categoryCell"
    
    //Alert
    static let deleteTit = "Delete"
    static let deleteMes = "Do you want to delete this record?"
    static let yes = "Yes"
    static let cancel = "Cancel"
    static let done = "Done"
    
    //Format
    static let dateFormat1 = "MMM yy"
    static let dateFormat2 = "yyyy-MM-dd"
    static let dateFormat3 = "dd/MM/yyyy"
    static let dayFormat1 = "dd"
    static let weekFormat1 = "EEE"
    static let monthFormat1 = "L"
    static let monthFormat2 = "LL"
    static let yearFormat1 = "y"
    static let xAxisFormat1 = "dd/MM"
    
    //UIFont
    static let chalkFont = "Chalkboard SE"
    static let chalkLight = "Chalkboard SE Light"
    static let chalkBold = "Chalkboard SE Bold"
    
    //Notification content
    static let noti_title = "Tomorrow You Have An Expense To Pay"
    static let noti_subtitle = "Note: "
    static let noti_body = "Amount: "
    
    //Default
    static let budget = "budget"
    static let isMonth = "isMonth"
    static let defaultYear = 2019
    static let defaultMonth = 1
    static let countDownLimit = 3
}
