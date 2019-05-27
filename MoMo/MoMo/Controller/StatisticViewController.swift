//
//  StatisticViewController.swift
//  MoMo
//
//  Created by BonnieLee on 20/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Charts
class StatisticViewController: UIViewController {

    var ref: DatabaseReference!
    var sumArray = [RecordSum]()
    var today = Date()
    var isMonth = true
    
    let string = Enum.StringList.self
    let limitShape = CAShapeLayer()
    let progressShape = CAShapeLayer()
    
    let calendar = Calendar.current
    var barsDict: [String:Double] = [:]
    var linesDict: [Int:Double] = [:]
    var weekTitle = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    var chartFont = UIFont()//UIFont(name: "Chalkboard SE", size: 10)!
    
    @IBOutlet weak var uv_progress: UIView!
    @IBOutlet weak var lb_average: UILabel!
    @IBOutlet weak var lb_spent: UILabel!
    @IBOutlet weak var tf_budget: UITextField!
    @IBOutlet weak var swt_mode_outlet: UISwitch!
    @IBOutlet weak var lb_week: UILabel!
    @IBOutlet weak var lb_month: UILabel!
    
    @IBOutlet weak var scDateRange: UISegmentedControl!
    @IBOutlet weak var outsideChartView: UIView!

    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var lineChartView: LineChartView!
    
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
    
    @IBAction func scDateRangeChange(_ sender: UISegmentedControl) {
        switch scDateRange.selectedSegmentIndex {
        case 0:
            updateChartRecordArray(.week)
        case 1:
            updateChartRecordArray(.month)
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uv_progress.layer.cornerRadius = 10;
        uv_progress.layer.masksToBounds = true;
        chartFont = UIFont(name: string.chalkFont.rawValue, size: 10)!
        tf_budget.text = "\(UserDefaults.standard.double(forKey: string.budget.rawValue))"
        ref = Database.database().reference().child(string.root.rawValue).child(string.date.rawValue)
        initChartViewStyle()
        updateChartRecordArray(.week)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        swt_mode_outlet.isOn = UserDefaults.standard.bool(forKey: string.isMonth.rawValue)
        isMonth = swt_mode_outlet.isOn
        loadRecordDateMonth(controller: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func setBarChartValues(dataPoints: [String], values: [Double]) {
        lineChartView.data = nil
        lineChartView.alpha = 0.0
        barChartView.alpha = 1.0
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        if let set = barChartView.data?.dataSets.first as? BarChartDataSet {
            set.replaceEntries(dataEntries)
            barChartView.data?.notifyDataChanged()
            barChartView.notifyDataSetChanged()
        }else {
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Money spent")
            chartDataSet.colors = [NSUIColor(red: 0.00, green: 0.33, blue: 0.58, alpha: 1.0)]
            chartDataSet.drawValuesEnabled = true
            let data = BarChartData(dataSet: chartDataSet)
            data.setValueFont(chartFont)
            barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
            barChartView.xAxis.labelFont = chartFont
            barChartView.data = data

            let leftAxisFormatter = NumberFormatter()
            leftAxisFormatter.negativePrefix = string.dollar.rawValue
            leftAxisFormatter.positivePrefix = string.dollar.rawValue
            barChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
            barChartView.leftAxis.labelFont = chartFont
            barChartView.rightAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
            barChartView.rightAxis.labelFont = chartFont
            barChartView.xAxis.labelPosition = .bottom
            
            //TODO: get the daily Average
            let ll1 = ChartLimitLine(limit: 150, label: "Daily Average: $150")
            ll1.lineWidth = 2
            ll1.lineDashLengths = [5, 5]
            ll1.labelPosition = .topRight
            ll1.valueFont = chartFont
            ll1.valueTextColor = .red
            barChartView.leftAxis.addLimitLine(ll1)
        }
    }
    
    func setLineChartValues(dataPoints: [Int], values: [Double]) {
        barChartView.data = nil
        lineChartView.alpha = 1.0
        barChartView.alpha = 0.0
        let dataEntries : [ChartDataEntry] = (0..<dataPoints.count).map{ (i) -> ChartDataEntry in
            return  ChartDataEntry(x: Double(i), y: values[i])
        }
        
        if let set = lineChartView.data?.dataSets.first as? LineChartDataSet {
            set.replaceEntries(dataEntries)
            lineChartView.data?.notifyDataChanged()
            lineChartView.notifyDataSetChanged()
        }else {
            let chartDataSet = LineChartDataSet(entries: dataEntries, label: "Monthly Money spent")
            chartDataSet.colors = [NSUIColor(red: 0.00, green: 0.33, blue: 0.58, alpha: 1.0)]
            chartDataSet.drawValuesEnabled = false
            let data = LineChartData(dataSet: chartDataSet)
            data.setValueFont(chartFont)
            let month = Date().getComponent(format: string.monthFormat2.rawValue)
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints.map{ (i) -> String in
                let day = i >= 9 ? "\(i + 1)" : "0\(i+1)"
                return "\(day)/\(month)"})
            lineChartView.xAxis.labelFont = chartFont
            lineChartView.data = data
            let leftAxisFormatter = NumberFormatter()
            leftAxisFormatter.negativePrefix = string.dollar.rawValue
            leftAxisFormatter.positivePrefix = string.dollar.rawValue
            lineChartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
            lineChartView.leftAxis.labelFont = chartFont
            lineChartView.rightAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
            lineChartView.rightAxis.labelFont = chartFont
            lineChartView.xAxis.labelPosition = .bottom
    
            let l = lineChartView.legend
            l.horizontalAlignment = .left
            l.verticalAlignment = .bottom
            l.orientation = .horizontal
            l.drawInside = false
            l.form = .circle
            l.formSize = 5
            l.font = chartFont
            l.xEntrySpace = 4
            
            chartDataSet.circleRadius = 3
            chartDataSet.setColor(NSUIColor(red:0.00, green:0.50, blue:0.76, alpha:1.0))
            chartDataSet.setCircleColor(NSUIColor(red:0.00, green:0.50, blue:0.76, alpha:1.0))
            
            //TODO: get the daily Average
            let ll1 = ChartLimitLine(limit: 150, label: "Daily Average: $150")
            ll1.lineWidth = 2
            ll1.lineDashLengths = [5, 5]
            ll1.labelPosition = .topRight
            ll1.valueFont = chartFont
            ll1.valueTextColor = .red
            lineChartView.leftAxis.addLimitLine(ll1)
            
            let marker = BalloonMarker(color: UIColor(red:0.00, green:0.50, blue:0.76, alpha:1.0),
                                       font: chartFont,
                                       textColor: .white,
                                       insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
            marker.chartView = lineChartView
            marker.minimumSize = CGSize(width: 80, height: 40)
            lineChartView.marker = marker
           
        }
    }
    
 
    func updateChartRecordArray(_ type: Enum.GraphType) {
        var dates: [Date]
        switch type {
        case .week:
            barsDict.removeAll()
            dates = getWeekDates()
            for date in dates {
                let dateStr = String("\(date)".prefix(10))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE"
                let weekName : String = dateFormatter.string(from: date)
                
                if self.barsDict[weekName] == nil{
                    self.barsDict[weekName] = 0
                }
                
                ref.child(dateStr).observe(.value, with: { (snapshot) in
                    var dayTotal: Double = 0
                    self.barsDict[weekName] = 0
                    if snapshot.childrenCount > 0 {
                        for record in snapshot.children.allObjects as! [DataSnapshot] {
                            let recordObject = record.value as? [String: AnyObject]
                            let amount = recordObject?[self.string.amount.rawValue] as! Double
                            dayTotal += amount
                        }
                    }
                    self.barsDict[weekName] = self.barsDict[weekName]! + dayTotal
 
                    let weekValues : [Double] = (0...(self.weekTitle.count-1)).map{ (i) -> Double in
                        let title = self.weekTitle[i]
                        return self.barsDict[title] == nil ? 0: self.barsDict[title]!
                    }
                    
                    self.setBarChartValues(dataPoints: self.weekTitle, values: weekValues)
                    
                })
            }
            break
            
        case .month:
            linesDict.removeAll()
            dates = getMonthTillToday()
            let dayTitle : [Int] = dates.map{(date) -> Int in
                let dayName = subStr(str: "\(date)", from: 8, length: 2)
                let day =  Int(dayName)
                self.linesDict[day!] = 0.0
                return day!
            }
            
            for date in dates {
                let dateStr = String("\(date)".prefix(10))
                let dayName : String = subStr(str: "\(date)", from: 8, length: 2 )
                let day =  Int(dayName)
                
                ref.child(dateStr).observe(.value, with: { (snapshot) in
                    var dayTotal: Double = 0
                    self.barsDict[dayName] = 0
                    if snapshot.childrenCount > 0 {
                        for record in snapshot.children.allObjects as! [DataSnapshot] {
                            let recordObject = record.value as? [String: AnyObject]
                            let amount = recordObject?[self.string.amount.rawValue] as! Double
                            dayTotal += amount
                        }
                    }
                    self.linesDict[day!] = self.linesDict[day!]! + dayTotal
                    let dayValues = (0...(dates.count-1)).map { i in
                        return self.linesDict[i] == nil ? 0 : self.linesDict[i]!
                    }
                    
                    self.setLineChartValues(dataPoints: dayTitle, values: dayValues)
                })
            }
            break
        }
    }
    
    // get the date of each day of the week
    func getWeekDates() -> [Date] {
        var comp = calendar.dateComponents([.year, .month, .day, .weekday], from: today)
        let currentWeekDay = comp.weekday == 1 ? 7 : (comp.weekday!  - 1)
        return getDatesByRange(from: 1 - currentWeekDay, to: 7-currentWeekDay)
    }
  
    // get the dates of each month of the day
    func getMonth() -> [Date] {
        var comp = calendar.dateComponents([.year, .month, .day, .weekday], from: today)
        guard let day = comp.day, let month = comp.month, let year = comp.year else {
            return []
        }
        return getDatesByRange(from: 1 - day, to: Date().getDaysInMonth(year: year, month: month) - day)
    }
    
    // get the dates of each month of the day
    func getMonthTillToday() -> [Date] {
        var comp = calendar.dateComponents([.year, .month, .day, .weekday], from: today)
        return comp.day == nil ? [] : getDatesByRange(from: 2 - comp.day!, to: 1)
    }
    
    // give a range of days, from means how many days before today; to means how many days after today
    func getDatesByRange(from: Int, to: Int) -> [Date] {
        var comp = calendar.dateComponents([.year, .month, .day, .weekday], from: today)
        guard let day = comp.day else {
            return []
        }

        let dates: [Date] = (from...to).map{ (i) -> Date in
            comp.day = day + i
            let date = calendar.date(from: comp)
            return date!
        }
        
        return dates
    }
    
    func subStr(str: String, from: Int, length: Int) -> String {
        let start = str.index(str.startIndex, offsetBy: from)
        let end = str.index(start, offsetBy: length)
        let range = start..<end
        let mySubstring = str[range]
        return String(mySubstring)
    }
    
    func initChartViewStyle() {
        barChartView.rightAxis.labelFont = chartFont
        barChartView.leftAxis.labelFont = chartFont
        barChartView.chartDescription?.text = string.blank.rawValue
        barChartView.noDataText = string.blank.rawValue
    }
}
