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
    var limitLine: ChartLimitLine = ChartLimitLine(limit: 0, label: "\(Consts.limitLineLabel): $\(0)")

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
        changeLimitLine()
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
        ChartUtils.setChartViewStyle(limitLine: limitLine, chart: uv_bar_chart)
        ChartUtils.setChartViewStyle(limitLine: limitLine, chart: uv_line_chart)
        ChartUtils.setMarker(chartView: uv_bar_chart)
        ChartUtils.setMarker(chartView: uv_line_chart)
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
            noOfDays = Consts.daysInAWeek
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
        let totalAmount: [Double] = array.map { amount in amount.amount}
        return round(totalAmount.reduce(0, +) * 100 ) / 100
    }
    
    
    func getDailyAverage(_ type: Enum.GraphType)-> Double {
        let budgetText = tf_budget.text ?? "0"
        let budget: Double = Double(budgetText) ?? 0.0
        let duration: Int
        switch type {
        case .week:
            duration = Consts.daysInAWeek
        default:
            duration = Date().getDaysInThisMonth()
        }
        let average = budget / Double(duration)
        return Double(round(100*average)/100);
    }
    
    func changeLimitLine() {
        var type: Enum.GraphType = .week
        var chart: BarLineChartViewBase = uv_bar_chart
        switch scDateRange.selectedSegmentIndex {
        case 0: // weekly chart
            type = .week
            chart = uv_bar_chart
        case 1: // monthly chart
            type = .month
            chart = uv_line_chart
        default:
            break
        }
        chart.data = nil
        updateChartRecordArray(type)
    }
    
    func setBarChartValues(_ dataPoints: [String], _ values: [Double]) {
        ChartUtils.switchView(fromView: uv_line_chart , toView: uv_bar_chart)
        let dataEntries: [BarChartDataEntry] = (0..<dataPoints.count).map { i in BarChartDataEntry(x: Double(i), y: values[i]) }
        
        if let set = uv_bar_chart.data?.dataSets.first as? BarChartDataSet {
            set.replaceEntries(dataEntries)
            uv_bar_chart.data?.notifyDataChanged()
            uv_bar_chart.notifyDataSetChanged()
        } else {
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: Consts.barLabel)
            let data = BarChartData(dataSet: chartDataSet)
            uv_bar_chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
            uv_bar_chart.data = data
            ChartUtils.setBarChartDataSetStyle(chartDataSet)
            ChartUtils.setYAxisMoneyFormatter(uv_bar_chart)
            
            let limit = getDailyAverage(.week)
            ChartUtils.updateLimitLine(limitLine: limitLine,
                                       axis: uv_bar_chart.leftAxis,
                                       limit: limit,
                                       label: "\(Consts.limitLineLabel) \(limit)")
        }
    }
    

    func setLineChartValues(_ dataPoints: [Int], _ values: [Double]) {
        ChartUtils.switchView(fromView: uv_bar_chart, toView: uv_line_chart)
        let dataEntries = (0..<dataPoints.count).map { i in ChartDataEntry(x: Double(i), y: values[i]) }
        
        if let set = uv_line_chart.data?.dataSets.first as? LineChartDataSet {
            set.replaceEntries(dataEntries)
            uv_line_chart.data?.notifyDataChanged()
            uv_line_chart.notifyDataSetChanged()
        } else {
            let chartDataSet = LineChartDataSet(entries: dataEntries, label: Consts.barLabel)
            
            let data = LineChartData(dataSet: chartDataSet)
            data.setValueFont(UIFont.chartFont)
            uv_line_chart.data = data
            ChartUtils.setAxisDateFormat(uv_line_chart, dataPoints: dataPoints)
            ChartUtils.setLineChartDataSetStyle(chartDataSet)
            ChartUtils.setYAxisMoneyFormatter(uv_line_chart)
            ChartUtils.setLengent(uv_line_chart.legend)
            let limit = getDailyAverage(.month)
            ChartUtils.updateLimitLine(limitLine: limitLine,
                                       axis: uv_line_chart.leftAxis, limit: limit,
                                       label: "\(Consts.limitLineLabel): $\(limit)")
        }
    }
    
    
    func updateChartRecordArray(_ type: Enum.GraphType) {
        switch type {
        case .week: // accumulate spense for each day of the week
            var barValues: [Double] = Array(repeating: 0.0, count: Consts.daysInAWeek)
            for date in Date().getWeekDates() {
                ref.child(String("\(date)".prefix(10))).observe(.value, with: { (snapshot) in
                    let weekName = Date().getWeekNameFromDate(date)
                    for record in snapshot.children.allObjects as! [DataSnapshot] {
                        let recordObject = record.value as? [String: AnyObject]
                        barValues[Consts.weekNumber[weekName]!] += recordObject?[self.string.amount.rawValue] as! Double
                    }
                    self.setBarChartValues(Consts.weekTitle, barValues)
                })
            }
        case .month: // accumulate spense for each day of the month
            let dates = Date().getMonthTillToday()
            let dayTitle = dates.map { date in Date().getDayIntValueFromDate(date) }
            var barValues: [Double] = Array(repeating: 0.0, count: dates.count+1)
            for date in dates {
                let day: Int = Date().getDayIntValueFromDate(date)
                ref.child(String("\(date)".prefix(10))).observe(.value, with: { (snapshot) in
                    for record in snapshot.children.allObjects as! [DataSnapshot] {
                        let recordObject = record.value as? [String: AnyObject]
                        let amount = recordObject?[self.string.amount.rawValue] as! Double
                        barValues[day] += amount
                    }
                    self.setLineChartValues(dayTitle, barValues)
                })
            }
        }
    }
}
