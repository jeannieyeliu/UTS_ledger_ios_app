//
//  Helper.swift
//  MoMo
//
//  Created by BonnieLee on 22/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//
import UIKit

extension UIViewController {
    
    func getDate(dateString: String, format: String = Enum.StringList.dateFormat2.rawValue) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: dateString)!
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return date
    }
    
    func getCountDown(from: String, to: String) -> Int {
        let countDown = Calendar.current.dateComponents([.day],
                                                        from: getDate(dateString: String("\(from)".prefix(10))),
                                                        to: getDate(dateString: to))
        if let number = Int("\(countDown)".components(separatedBy:CharacterSet.decimalDigits.inverted).joined()) {
            return number
        }
        return 0
    }
    
    func getCorrectDate(forDate: Date) -> String {
        let correctDate = Calendar.current.date(byAdding: .day, value: 1, to: forDate)!
        return String("\(correctDate)".prefix(10))
    }
    
    func getNumberOfDaysInAMonth() -> Int {
        let month = Date().getComponent(format: Enum.StringList.monthFormat1.rawValue)
        let year = Date().getComponent(format: Enum.StringList.yearFormat1.rawValue)
        return Date().getDaysInMonth(year: Int(year) ?? 2019, month: Int(month) ?? 1)
    }
    
    func getDaysPassedMonth() -> Int {
        let startOfMonth = getCorrectDate(forDate: Date().startOfMonth())
        return getCountDown(from: String("\(startOfMonth)".prefix(10)), to: String("\(Date())".prefix(10)))
    }
    
    func getDaysPassedWeek() -> Int {
        let startOfWeek = getCorrectDate(forDate: Date().startOfWeek())
        return getCountDown(from: String("\(startOfWeek)".prefix(10)), to: String("\(Date())".prefix(10)))
    }
}

extension UIColor {
    static let lightBlue = UIColor(red: 0.90, green: 0.96, blue: 1.00, alpha: 1.0)
    static let oceanBlue = UIColor(red: 0.00, green: 0.50, blue: 0.76, alpha: 1.0)
    static let darkBlue = UIColor(red: 0.00, green: 0.33, blue: 0.58, alpha: 1.0)
}

extension UIFont {
    static let chartFont = UIFont(name: Enum.StringList.chalkFont.rawValue, size: 10)!
}
extension Calendar {
    static let iso8601 = Calendar(identifier: .iso8601)
}

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    func startOfWeek() -> Date {
        return Calendar.iso8601.date(from: Calendar.iso8601.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
    
    func getCurrentWeek(from date: Date) -> Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar.component(.weekOfYear, from: date)
    }
    
    func getCurrentMonth(from date: Date) -> Int {
        return Calendar.current.component(.month, from: date)
    }
    
    func getComponent(format: String) -> String {
        let formatter = DateFormatter()
        let today = Date()
        formatter.dateFormat = format
        return formatter.string(from: today)
    }
    
    func getDaysInMonth(year: Int, month: Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    func getDaysInThisMonth() -> Int {
        var comp = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: Date())
        let year = comp.year ?? 2019
        let month = comp.month ?? 5
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    func isLessThanToday(today: Date, and: Date) -> Bool {
        return today >= and
    }
    
//    func getMonth(from date: today) -> [Date] {
//        let calendar = Calendar.current
//        var comp = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
//        guard let day = comp.day, let month = comp.month, let year = comp.year else {
//            return []
//        }
//        return getDatesByRange(from: 1 - day, to: Date().getDaysInMonth(year: year, month: month) - day)
//    }
    
    
    // get the date of each day of the week
    func getWeekDates() -> [Date] {
        var comp = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: Date())
        let currentWeekDay = comp.weekday == 1 ? 7 : (comp.weekday!  - 1)
        return getDatesByRange(from: 1 - currentWeekDay, to: 7-currentWeekDay)
    }
    
    // get the dates of each month of the day
    func getMonth() -> [Date] {
        var comp = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: Date())
        guard let day = comp.day, let month = comp.month, let year = comp.year else {
            return []
        }
        return getDatesByRange(from: 1 - day, to: Date().getDaysInMonth(year: year, month: month) - day)
    }
    
    // get the dates of each month of the day
    func getMonthTillToday() -> [Date] {
        var comp = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: Date())
        return comp.day == nil ? [] : getDatesByRange(from: 2 - comp.day!, to: 1)
    }
    
    // give a range of days, from means how many days before today; to means how many days after today
    func getDatesByRange(from: Int, to: Int) -> [Date] {
        var comp = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: Date())
        guard let day = comp.day else {
            return []
        }
        
        let dates: [Date] = (from...to).map { (i) -> Date in
            comp.day = day + i
            let date = Calendar.current.date(from: comp)
            return date!
        }
        return dates
    }
    
    func getWeekNameFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        dateFormatter.timeZone = TimeZone.current
        let correctDate = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        return dateFormatter.string(from: correctDate )
    }
    
    func getDayIntValueFromDate(_ date: Date) -> Int {
        let dayName = String.subStr(str: "\(date)", from: 8, length: 2)
        return Int(dayName)!
    }
}

extension String {
    // Swift 4 doesn't provide direct substring so...
    static func subStr(str: String, from: Int, to: Int) -> String {
        return subStr(str:str, from: from, length: to - from)
    }
    
    static func subStr(str: String, from: Int, length: Int) -> String {
        let start = str.index(str.startIndex, offsetBy: from)
        let end = str.index(start, offsetBy: length)
        let range = start..<end
        let mySubstring = str[range]
        return String(mySubstring)
    }
    
    // return 2 digit for a number, e.g. format(1) will return "01"
    static func formatTwoDigit(_ digit: Int) -> String {
        return digit >= 9 ? "\(digit + 1)" : "0\(digit+1)"
    }
    
    // formatDayMonth(day: 2, month: 1) will return "02/01)
    static func formatDayMonth(day: Int, month: Int) -> String {
        return "\(formatTwoDigit(day))/\(formatTwoDigit(month))"
    }
    
    
    static func formatDayMonth(day: Int, month: String) -> String {
        return "\(formatTwoDigit(day))/\(formatTwoDigit(Int(month)!))"
    }
}
