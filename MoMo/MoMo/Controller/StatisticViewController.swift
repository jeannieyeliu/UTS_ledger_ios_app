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

    // MARK: Variables
    var ref: DatabaseReference!
    var sumArray = [RecordSum]()
    var today = Date()
    let calendar = Calendar.current
    var isMonth = true
    let string = Enum.StringList.self
    let limitShape = CAShapeLayer()
    let progressShape = CAShapeLayer()
    var barsDict: [String:Double] = [:]
    var linesDict: [Int:Double] = [:]
    
    // MARK: IBOutlet
    @IBOutlet weak var uv_progress: UIView!
    @IBOutlet weak var lb_average: UILabel!
    @IBOutlet weak var lb_spent: UILabel!
    @IBOutlet weak var tf_budget: UITextField!
    @IBOutlet weak var swt_mode_outlet: UISwitch!
    @IBOutlet weak var lb_week: UILabel!
    @IBOutlet weak var lb_month: UILabel!
    @IBOutlet weak var scDateRange: UISegmentedControl!
    @IBOutlet weak var uv_bar_chart: BarChartView!
    @IBOutlet weak var uv_line_chart: LineChartView!
    
    // MARK: IBAction
    @IBAction func tf_budget_change(_ sender: UITextField) {
        let budgetText: String = sender.text ?? string.zeroDouble.rawValue
        let budget = Double(budgetText) ?? 0.0
        UserDefaults.standard.set(budget, forKey: string.budget.rawValue)
        loadRecordDateMonth(controller: self)
    }
    
    @IBAction func btn_back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // switch the data of the budget/daily average/progress bar for month and week
    @IBAction func swt_mode(_ sender: UISwitch) {
        isMonth = isMonth ? false : true
        loadRecordDateMonth(controller: self)
        UserDefaults.standard.set(isMonth, forKey: string.isMonth.rawValue)
    }
    
    @IBAction func scDateRangeChange(_ sender: UISegmentedControl) {
        switch scDateRange.selectedSegmentIndex {
        case 0: // display the weekly chart
            updateChartRecordArray(.week)
        case 1: // display the monthly chart
            updateChartRecordArray(.month)
        default:
            break
        }
    }
    
    // MARK: Inherited view funtions
    override func viewDidLoad() {
        super.viewDidLoad()
        uv_progress.layer.cornerRadius = 10;
        uv_progress.layer.masksToBounds = true;
        tf_budget.text = "\(UserDefaults.standard.double(forKey: string.budget.rawValue))"
        ref = Database.database().reference().child(string.root.rawValue).child(string.date.rawValue)
        setChartViewStyle(chart: uv_bar_chart)
        setChartViewStyle(chart: uv_line_chart)
        updateChartRecordArray(Consts.defaultChartType)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        swt_mode_outlet.isOn = UserDefaults.standard.bool(forKey: string.isMonth.rawValue)
        isMonth = swt_mode_outlet.isOn
        loadRecordDateMonth(controller: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tf_budget.resignFirstResponder()
    }
    
    // Set total amount for the progress bar
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
        let noOfDays = isMonth ? getNumberOfDaysInAMonth() : 7
        var daysPassed = isMonth ? getDaysPassedMonth() : getDaysPassedWeek()
        daysPassed = daysPassed == 0 ? 1 : daysPassed
        let shouldSpend = budget / Double(noOfDays) * Double(daysPassed)
        
        return CGFloat(shouldSpend * Double(uv_progress.bounds.width) / budget)
    }
    
    func getDaysLeft() -> Int {
        var noOfDays = 0
        var daysPassed = 0
        
        if isMonth {
            noOfDays = getNumberOfDaysInAMonth()
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
    
    func setChartViewStyle(chart: BarLineChartViewBase) {
        // set style for bar chart
        chart.rightAxis.labelFont = UIFont.chartFont
        chart.leftAxis.labelFont = UIFont.chartFont
        chart.xAxis.labelFont = UIFont.chartFont
        chart.chartDescription?.text = string.blank.rawValue
        chart.noDataText = string.blank.rawValue
    }
    
    func setBarChartValues(dataPoints: [String], values: [Double]) {
        changeView(fromView: uv_line_chart , toView: uv_bar_chart)
        let dataEntries: [BarChartDataEntry] = (0..<dataPoints.count).map { (i) in
            return BarChartDataEntry(x: Double(i), y: values[i])
        }
//        for i in 0..<dataPoints.count {
//            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
//            dataEntries.append(dataEntry)
//        }
//
        if let set = uv_bar_chart.data?.dataSets.first as? BarChartDataSet {
            set.replaceEntries(dataEntries)
            uv_bar_chart.data?.notifyDataChanged()
            uv_bar_chart.notifyDataSetChanged()
        }else {
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Money spent")
            chartDataSet.colors = [NSUIColor(red: 0.00, green: 0.33, blue: 0.58, alpha: 1.0)]
            chartDataSet.drawValuesEnabled = true
            let data = BarChartData(dataSet: chartDataSet)
            data.setValueFont(UIFont.chartFont)
            uv_bar_chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
            uv_bar_chart.data = data
            
            let leftAxisFormatter = NumberFormatter()
            leftAxisFormatter.negativePrefix = string.dollar.rawValue
            leftAxisFormatter.positivePrefix = string.dollar.rawValue
            uv_bar_chart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
            uv_bar_chart.leftAxis.labelFont = UIFont.chartFont
            uv_bar_chart.rightAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
            uv_bar_chart.rightAxis.labelFont = UIFont.chartFont
            
            let limitLine = ChartLimitLine(limit: 150, label: "Daily Average: $150")
            limitLine.lineWidth = 2
            limitLine.lineDashLengths = [5, 5]
            limitLine.labelPosition = .topRight
            limitLine.valueFont = UIFont.chartFont
            limitLine.valueTextColor = .red
            uv_bar_chart.leftAxis.addLimitLine(limitLine)
        }
    }
    
    func setLineChartValues(dataPoints: [Int], values: [Double]) {
        changeView(fromView: uv_bar_chart, toView: uv_line_chart)
        let dataEntries : [ChartDataEntry] = (0..<dataPoints.count).map { (i) -> ChartDataEntry in
            return  ChartDataEntry(x: Double(i), y: values[i])
        }
        
        if let set = uv_line_chart.data?.dataSets.first as? LineChartDataSet {
            set.replaceEntries(dataEntries)
            uv_line_chart.data?.notifyDataChanged()
            uv_line_chart.notifyDataSetChanged()
        }else {
            let chartDataSet = LineChartDataSet(entries: dataEntries, label: "Monthly Money spent")
            chartDataSet.colors = [NSUIColor(red: 0.00, green: 0.33, blue: 0.58, alpha: 1.0)]
            chartDataSet.drawValuesEnabled = false
            let data = LineChartData(dataSet: chartDataSet)
            data.setValueFont(UIFont.chartFont)
            let month = Date().getComponent(format: string.monthFormat2.rawValue)
            uv_line_chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints.map { (i) -> String in
                let day = i >= 9 ? "\(i + 1)" : "0\(i+1)"
                return "\(day)/\(month)"})
            uv_line_chart.xAxis.labelFont = UIFont.chartFont
            uv_line_chart.data = data
            let leftAxisFormatter = NumberFormatter()
            leftAxisFormatter.negativePrefix = string.dollar.rawValue
            leftAxisFormatter.positivePrefix = string.dollar.rawValue
            uv_line_chart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
            uv_line_chart.leftAxis.labelFont = UIFont.chartFont
            uv_line_chart.rightAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
            
            uv_line_chart.xAxis.labelPosition = .bottom
    
            let l = uv_line_chart.legend
            l.horizontalAlignment = .left
            l.verticalAlignment = .bottom
            l.orientation = .horizontal
            l.drawInside = false
            l.form = .circle
            l.formSize = 5
            l.font = UIFont.chartFont
            l.xEntrySpace = 4
            
            chartDataSet.circleRadius = 3
            chartDataSet.setColor(NSUIColor(red:0.00, green:0.50, blue:0.76, alpha:1.0))
            chartDataSet.setCircleColor(NSUIColor(red:0.00, green:0.50, blue:0.76, alpha:1.0))
            
            //TODO: get the daily Average
            let ll1 = ChartLimitLine(limit: 150, label: "Daily Average: $150")
            ll1.lineWidth = 2
            ll1.lineDashLengths = [5, 5]
            ll1.labelPosition = .topRight
            ll1.valueFont = UIFont.chartFont
            ll1.valueTextColor = .red
            uv_line_chart.leftAxis.addLimitLine(ll1)
            
            let marker = BalloonMarker(color: UIColor(red:0.00, green:0.50, blue:0.76, alpha:1.0),
                                       font: UIFont.chartFont,
                                       textColor: .white,
                                       insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
            marker.chartView = uv_line_chart
            marker.minimumSize = CGSize(width: 80, height: 40)
            uv_line_chart.marker = marker
           
        }
    }
    
 
    func updateChartRecordArray(_ type: Enum.GraphType) {
        var dates: [Date]
        switch type {
        case .week:
            barsDict.removeAll()
            dates = Date().getWeekDates()
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
 
                    let weekValues : [Double] = (0...(Consts.weekTitle.count-1)).map { (i) -> Double in
                        let title = Consts.weekTitle[i]
                        return self.barsDict[title] == nil ? 0: self.barsDict[title]!
                    }
                    
                    self.setBarChartValues(dataPoints: Consts.weekTitle, values: weekValues)
                    
                })
            }
            break
            
        case .month:
            linesDict.removeAll()
            dates = Date().getMonthTillToday()
            let dayTitle : [Int] = dates.map { (date) -> Int in
                let dayName = String().subStr(str: "\(date)", from: 8, length: 2)
                let day =  Int(dayName)
                self.linesDict[day!] = 0.0
                return day!
            }
            
            for date in dates {
                let dateStr = String("\(date)".prefix(10))
                let dayName : String = String().subStr(str: "\(date)", from: 8, length: 2 )
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
    
    // change to another view
    func changeView(fromView: BarLineChartViewBase, toView: BarLineChartViewBase) {
        fromView.data = nil
        fromView.alpha = 0.0
        toView.alpha = 1.0
    }
}
