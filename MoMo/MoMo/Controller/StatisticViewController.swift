//
//  StatisticViewController.swift
//  MoMo
//
//  Created by BonnieLee on 20/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import UIKit
import Firebase

class StatisticViewController: UIViewController {

    var ref: DatabaseReference!
    var sumArray = [RecordSum]()
    var today = Date()
    var isMonth = true
    
    let string = Enum.StringList.self
    let limitShape = CAShapeLayer()
    let progressShape = CAShapeLayer()
    
    @IBOutlet weak var uv_progress: UIView!
    @IBOutlet weak var lb_average: UILabel!
    @IBOutlet weak var lb_spent: UILabel!
    @IBOutlet weak var tf_budget: UITextField!
    @IBOutlet weak var swt_mode_outlet: UISwitch!
    @IBOutlet weak var lb_week: UILabel!
    @IBOutlet weak var lb_month: UILabel!
    
    @IBAction func tf_budget_change(_ sender: UITextField) {
        let budgetText: String = sender.text ?? string.zeroDouble.rawValue
        let budget = Double(budgetText) ?? 0.0
        UserDefaults.standard.set(budget, forKey: string.budget.rawValue)
        loadRecordDateMonth(controller: self)
    }
    @IBAction func btn_back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func swt_mode(_ sender: UISwitch) {
        isMonth = isMonth ? false : true
        loadRecordDateMonth(controller: self)
        UserDefaults.standard.set(isMonth, forKey: string.isMonth.rawValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uv_progress.layer.cornerRadius = 10;
        uv_progress.layer.masksToBounds = true;
        tf_budget.text = "\(UserDefaults.standard.double(forKey: string.budget.rawValue))"
        ref = Database.database().reference().child(string.root.rawValue).child(string.date.rawValue)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        swt_mode_outlet.isOn = UserDefaults.standard.bool(forKey: string.isMonth.rawValue)
        isMonth = swt_mode_outlet.isOn
        loadRecordDateMonth(controller: self)
    }
    
    func setTotalAmount (_ spent: Double) {
        guard let budgetText = tf_budget.text else { return }
        let budget: Double = Double(budgetText) ?? 0.0
        let daysLeft = getDaysLeft()
        let average = getAverageSpending(budget: budget, spent: spent, daysLeft: daysLeft)
        
        lb_spent.text = "\(string.dollar.rawValue)\(spent)"
        lb_average.text = average == 0 ? string.overused.rawValue : "\(string.dollar.rawValue)\(average)"
        
        let limitX = getLimitX(budget: budget)
        let progressX = spent * Double(uv_progress.bounds.width) / budget
        
        let limitPath = UIBezierPath()
        limitPath.move(to: CGPoint(x: limitX, y: 3))
        limitPath.addLine(to: CGPoint(x: limitX, y: uv_progress.bounds.maxY - 3))
        
        limitShape.path = limitPath.cgPath
        limitShape.strokeColor = UIColor.lightBlue.cgColor
        limitShape.lineWidth = 3.0
        
        progressShape.path = UIBezierPath(rect: CGRect(x: 0.0, y: 0.0, width: CGFloat(progressX), height: uv_progress.bounds.maxY)).cgPath
        progressShape.fillColor = getProgressColor(limit: Double(limitX), progress: progressX).cgColor
        
        uv_progress.layer.addSublayer(progressShape)
        uv_progress.layer.addSublayer(limitShape)
    }
    
    func getProgressColor(limit: Double, progress: Double) -> UIColor {
        let result = progress / limit * 100
        switch result {
        case 0...50:
            return UIColor.oceanBlue
        case 50...100:
            return UIColor.darkBlue
        default:
            return UIColor.red
        }
    }
    
    func getLimitX(budget: Double) -> CGFloat {
        let noOfDays = isMonth ? getNumberOfDay() : 7
        var daysPassed = isMonth ? getDaysPassedMonth() : getDaysPassedWeek()
        daysPassed = daysPassed == 0 ? 1 : daysPassed
        let shouldSpend = budget / Double(noOfDays) * Double(daysPassed)
        
        return CGFloat(shouldSpend * Double(uv_progress.bounds.width) / budget)
    }
    
    func getDaysLeft() -> Int {
        var noOfDays = 0
        var daysPassed = 0
        
        if isMonth {
            noOfDays = getNumberOfDay()
            daysPassed = getDaysPassedMonth()
        } else {
            noOfDays = 7
            daysPassed = getDaysPassedWeek()
        }
        return  noOfDays - daysPassed
    }
    
    func getAverageSpending(budget: Double, spent: Double, daysLeft: Int) -> Double {
        let average = round((budget - spent) / Double(daysLeft) * 100) / 100
        return average > 0 ? average : 0
    }
    
    func getNumberOfDay() -> Int {
        let month = Date().getComponent(format: string.monthFormat1.rawValue)
        let year = Date().getComponent(format: string.yearFormat1.rawValue)
        return Date().getDaysInMonth(year: Int(year) ?? 2019, month: Int(month) ?? 1)
    }
    
    func getDaysPassedMonth() -> Int {
        let startOfMonth = getCorrectDate(forDate: Date().startOfMonth())
        return getCountDown(from: String("\(startOfMonth)".prefix(10)), to: String("\(today)".prefix(10)))
    }
    
    func getDaysPassedWeek() -> Int {
        let startOfWeek = getCorrectDate(forDate: Date().startOfWeek())
        return getCountDown(from: String("\(startOfWeek)".prefix(10)), to: String("\(today)".prefix(10)))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tf_budget.resignFirstResponder()
    }
    
    func loadRecordDateMonth (controller: StatisticViewController) {
        ref.observe(.value, with: { (snapshot) in
            self.sumArray.removeAll()
            var systemCalendar = Int()
            var recordCalendar = Int()
            
            if snapshot.childrenCount > 0 {
                for record in snapshot.children.allObjects as! [DataSnapshot] {
                    systemCalendar = self.isMonth ? Date().getCurrentMonth(from: self.today) : Date().getCurrentWeek(from: self.today)
                    recordCalendar = self.isMonth
                        ? Date().getCurrentMonth(from: self.getDate(dateString: record.key))
                        : Date().getCurrentWeek(from: self.getDate(dateString: record.key))
                    
                    if systemCalendar == recordCalendar
                        && Date().isLessThanToday(today: self.today, and: self.getDate(dateString: record.key)) {
                        
                        for id in record.children.allObjects as! [DataSnapshot] {
                            let object = id.value as? [String: AnyObject]
                            let amount = object?[self.string.amount.rawValue]
                            self.sumArray.append(RecordSum(amount: amount as! Double))
                        }
                    }
                }
                controller.setTotalAmount(self.getTotalAmount(array: self.sumArray))
            }
        })
    }
    
    func getTotalAmount(array: [RecordSum]) -> Double {
        var totalAmount = [Double]()
        for amount in array {
            totalAmount.append(amount.amount)
        }
        return round(totalAmount.reduce(0, +) * 100 ) / 100
    }
}

