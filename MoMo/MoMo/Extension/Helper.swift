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
}

extension UIColor {
    static let lightBlue = UIColor(red: 0.90, green: 0.96, blue: 1.00, alpha: 1.0)
    static let oceanBlue = UIColor(red: 0.00, green: 0.50, blue: 0.76, alpha: 1.0)
    static let darkBlue = UIColor(red: 0.00, green: 0.33, blue: 0.58, alpha: 1.0)
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
    
    func getDaysInMonth(year: Int, month: Int) -> Int{
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    func isLessThanToday(today: Date, and: Date) -> Bool {
        return today >= and
    }
}
