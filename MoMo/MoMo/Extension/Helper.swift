//
//  Helper.swift
//  MoMo
//
//  Created by BonnieLee on 22/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//
import UIKit

// This is collection of extensions
extension UIViewController {
    
    // Convert a string with a specific format to a date
    func getDate(dateString: String, format: String = Const.dateFormat2) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: dateString)!
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return date
    }
    
    // Calculate the difference between two days
    func getCountDown(from: String, to: String) -> Int {
        let countDown = Calendar.current.dateComponents([.day],
                                                        from: getDate(dateString: from.getShortDate()),
                                                        to: getDate(dateString: to))
        if let number = Int("\(countDown)".components(separatedBy:CharacterSet.decimalDigits.inverted).joined()) {
            return number
        }
        return Const.zero
    }
    
    // Because of the timezone problem, the date got from the calendar function is always less than today 1 day -> add 1 more day
    func getCorrectDate(forDate: Date) -> String {
        let correctDate = Calendar.current.date(byAdding: .day, value: 1, to: forDate)!
        return correctDate.getShortDate()
    }
    
    func getNumberOfDaysInAMonth() -> Int {
        let month = Date().getComponent(format: Const.monthFormat1)
        let year = Date().getComponent(format: Const.yearFormat1)
        return Date().getDaysInMonth(year: Int(year) ?? Const.defaultYear, month: Int(month) ?? Const.defaultMonth)
    }
    
    func getDaysPassedMonth() -> Int {
        let startOfMonth = getCorrectDate(forDate: Date().startOfMonth())
        return getCountDown(from: startOfMonth.getShortDate(), to: Date().getShortDate())
    }
    
    func getDaysPassedWeek() -> Int {
        let startOfWeek = getCorrectDate(forDate: Date().startOfWeek())
        return getCountDown(from: startOfWeek.getShortDate(), to: Date().getShortDate())
    }
    
    // Source: https://github.com/goktugyil/EZSwiftExtensions
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIColor {
    static let lightBlue = UIColor(red: 0.90, green: 0.96, blue: 1.00, alpha: 1.0)
    static let oceanBlue = UIColor(red: 0.00, green: 0.50, blue: 0.76, alpha: 1.0)
    static let darkBlue = UIColor(red: 0.00, green: 0.33, blue: 0.58, alpha: 1.0)
}

extension UIFont {
    static let chartFont = UIFont(name: Const.chalkFont, size: 10)!
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
    
    // Get a component from a specific format (e.g. d, mm, yyyy, etc.)
    func getComponent(format: String) -> String {
        let formatter = DateFormatter()
        let today = Date()
        formatter.dateFormat = format
        return formatter.string(from: today)
    }
    
    func getShortDate() -> String {
        return String("\(self)".prefix(Const.datePrefix))
    }
    
    func getDaysInMonth(year: Int, month: Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    func getDaysInThisMonth() -> Int {
        let comp = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: Date())
        let year = comp.year ?? Const.defaultYear
        let month = comp.month ?? Const.defaultMonth
        let range = getDaysInMonth(year: year, month: month)
        return range
    }
    
    func isLessThanToday(today: Date, and: Date) -> Bool {
        return today >= and
    }
    
    func getWeekNameFromDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Const.weekFormat1
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date )
    }
    
    func getXAxisFormatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Const.xAxisFormat1
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date)
    }
    
    func getFormatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Const.dateFormat3
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date)
    }
    
    func getLastNDays(_ lastNDay: Int) -> [Date] {
        return (1 ... lastNDay).map {
            Calendar.current.date(byAdding: .day, value: $0 - lastNDay, to: Date())!
        }
    }
}

extension String {
    func getShortDate() -> String {
        return String(self.prefix(Const.datePrefix))
    }
}

extension UITextField {
    
    // Source: https://gist.github.com/jplazcano87/8b5d3bc89c3578e45c3e
    func addDoneButtonToKeyboard(myAction:Selector?) {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: Const.zero, y: Const.zero, width: 300, height: 40))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: Const.done,
                                                    style: UIBarButtonItem.Style.done,
                                                    target: self, action: myAction)
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
}
