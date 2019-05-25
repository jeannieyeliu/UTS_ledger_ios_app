//
//  Helper.swift
//  MoMo
//
//  Created by BonnieLee on 22/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//
import UIKit

extension HomeViewController {
    func getDate(dateString: String, format: String = "yyyy-MM-dd") -> Date {
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
