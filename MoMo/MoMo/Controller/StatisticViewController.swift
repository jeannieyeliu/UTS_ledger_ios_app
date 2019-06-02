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
    let calendar = Calendar.current
    let limitShape = CAShapeLayer()
    let progressShape = CAShapeLayer()
    let zero = 0
    
    var ref: DatabaseReference!
    var sumArray = [RecordSum]()
    var today = Date()
    var isMonth = true
    var limitLine: ChartLimitLine = ChartLimitLine(limit: 0, label: "\(Const.limitLineLabel): \(Const.dollar)\(0)")
    var showLimitLine = true
    
    // MARK: IBOutlet
    @IBOutlet weak var uv_progress: UIView!
    @IBOutlet weak var lb_average: UILabel!
    @IBOutlet weak var lb_spent: UILabel!
    @IBOutlet weak var tf_budget: UITextField!
    @IBOutlet weak var swt_mode_outlet: UISwitch!
    @IBOutlet weak var lb_week: UILabel!
    @IBOutlet weak var lb_month: UILabel!
    @IBOutlet weak var sc_DateRange: UISegmentedControl!
    @IBOutlet weak var uv_bar_chart: BarChartView!
    @IBOutlet weak var uv_line_chart: LineChartView!
    
    // MARK: IBAction
    @IBAction func tf_budget_change(_ sender: UITextField) {
        let budgetText: String = sender.text ?? Const.zeroDouble
        let budget = Double(budgetText) ?? Double(zero)
        UserDefaults.standard.set(budget, forKey: Const.budget)
        loadRecordDateMonth(controller: self)
        changeLimitLine()
    }
    
    @IBAction func btn_back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // switch the statistic mode to month / week
    @IBAction func swt_mode(_ sender: UISwitch) {
        isMonth = isMonth ? false : true
        loadRecordDateMonth(controller: self)
        changeLimitLine()
        UserDefaults.standard.set(isMonth, forKey: Const.isMonth)
    }
    
    @IBAction func sc_DateRangeChange(_ sender: UISegmentedControl) {
        switch sc_DateRange.selectedSegmentIndex {
        case 0: // display the weekly chart
            changeLimitLine()
        case 1: // display the monthly chart
            changeLimitLine()
        default:
            break
        }
    }
    
    // MARK: Inherited view funtions
    override func viewDidLoad() {
        super.viewDidLoad()
        uv_progress.layer.cornerRadius = 10;
        uv_progress.layer.masksToBounds = true;
        tf_budget.text = "\(UserDefaults.standard.double(forKey: Const.budget))"
        ref = Database.database().reference().child(Const.root).child(Const.date)
        ChartUtils.setChartViewStyle(limitLine: limitLine, chart: uv_bar_chart, showLimitLine: false)
        ChartUtils.setChartViewStyle(limitLine: limitLine, chart: uv_line_chart, showLimitLine: false)
        ChartUtils.setMarker(chartView: uv_bar_chart, lastNDays: Const.daysInAWeek)
        ChartUtils.setMarker(chartView: uv_line_chart, lastNDays: Const.daysInAMonth)
        updateChartRecordArray(Const.defaultChartType)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        swt_mode_outlet.isOn = UserDefaults.standard.bool(forKey: Const.isMonth)
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
        let budget: Double = Double(budgetText) ?? Double(zero)
        let daysLeft = getDaysLeft()
        let average = getAverageSpending(budget: budget, spent: spent, daysLeft: daysLeft)
        
        lb_spent.text = "\(Const.dollar)\(spent)"
        lb_average.text = average == Double(zero) ? Const.overused : "\(Const.dollar)\(average)"
        
        let limitX = getLimitX(budget: budget)
        let progressX = spent * Double(uv_progress.bounds.width) / budget
        
        let limitPath = UIBezierPath()
        limitPath.move(to: CGPoint(x: limitX, y: 3))
        limitPath.addLine(to: CGPoint(x: limitX, y: uv_progress.bounds.maxY - 3))
        
        limitShape.path = limitPath.cgPath
        limitShape.strokeColor = UIColor.lightBlue.cgColor
        limitShape.lineWidth = 3.0
        
        progressShape.path = UIBezierPath(rect: CGRect(x: CGFloat(zero), y: CGFloat(zero),
                                                       width: CGFloat(progressX), height: uv_progress.bounds.maxY)).cgPath
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
        daysPassed = daysPassed == zero ? 1 : daysPassed
        let shouldSpend = budget / Double(noOfDays) * Double(daysPassed)
        
        return CGFloat(shouldSpend * Double(uv_progress.bounds.width) / budget)
    }
    
    func getDaysLeft() -> Int {
        var noOfDays = zero
        var daysPassed = zero
        if isMonth {
            noOfDays = getNumberOfDaysInAMonth()
            daysPassed = getDaysPassedMonth()
        } else {
            noOfDays = Const.daysInAWeek
            daysPassed = getDaysPassedWeek()
        }
        return  noOfDays - daysPassed
    }
    
    func getAverageSpending(budget: Double, spent: Double, daysLeft: Int) -> Double {
        let average = round((budget - spent) / Double(daysLeft) * 100) / 100
        return average > Double(zero) ? average : Double(zero)
    }
    
    func loadRecordDateMonth (controller: StatisticViewController) {
        ref.observe(.value, with: { (snapshot) in
            self.sumArray.removeAll()
            var systemCalendar = Int()
            var recordCalendar = Int()
            
            if snapshot.childrenCount > self.zero {
                for record in snapshot.children.allObjects as! [DataSnapshot] {
                    systemCalendar = self.isMonth ? Date().getCurrentMonth(from: self.today) : Date().getCurrentWeek(from: self.today)
                    recordCalendar = self.isMonth
                        ? Date().getCurrentMonth(from: self.getDate(dateString: record.key))
                        : Date().getCurrentWeek(from: self.getDate(dateString: record.key))
                    
                    if systemCalendar == recordCalendar
                        && Date().isLessThanToday(today: self.today, and: self.getDate(dateString: record.key)) {
                        
                        for id in record.children.allObjects as! [DataSnapshot] {
                            let object = id.value as? [String: AnyObject]
                            let amount = object?[Const.amount]
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
        let budgetText = tf_budget.text ?? Const.zeroDouble
        let budget: Double = Double(budgetText) ?? Double(zero)
        let duration: Int
        switch type {
        case .week:
            duration = Const.daysInAWeek
        default:
            duration = Date().getDaysInThisMonth()
        }
        let average = budget / Double(duration)
        return Double(round(100 * average) / 100);
    }
    
    func changeLimitLine() {
        var type: Enum.GraphType = .week
        var chart: BarLineChartViewBase = uv_bar_chart
        switch sc_DateRange.selectedSegmentIndex {
            case 0: // weekly chart
                type = .week
                chart = uv_bar_chart
                showLimitLine = swt_mode_outlet.isOn ? false : true
            case 1: // monthly chart
                type = .month
                chart = uv_line_chart
                showLimitLine = swt_mode_outlet.isOn ? true : false
            default:
                break
        }
        print("changeLimitLine \(showLimitLine)")
        chart.data = nil
        updateChartRecordArray(type)
    }
    
    func setBarChartValues(_ dataPoints: [Date], _ values: [Double]) {
        ChartUtils.switchView(fromView: uv_line_chart , toView: uv_bar_chart)
        let dataEntries: [BarChartDataEntry] = (zero..<dataPoints.count).map{ BarChartDataEntry(x: Double($0), y: values[$0]) }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: Const.barLabel)
        chartDataSet.setColor(UIColor.darkBlue)
        chartDataSet.colors = [UIColor.darkBlue]
        
        let data = BarChartData(dataSet: chartDataSet)
        data.setValueFont(UIFont.chartFont)
        uv_bar_chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints.map{ Date().getWeekNameFromDate($0) })
        uv_bar_chart.data = data
        ChartUtils.setBarChartDataSetStyle(chartDataSet)
        ChartUtils.setYAxisMoneyFormatter(uv_bar_chart)
        ChartUtils.setLegend(uv_bar_chart.legend)
        
        guard let budgetText = tf_budget.text else { return }
        let spend = self.getTotalAmount(array: self.sumArray)
        let budget: Double = Double(budgetText) ?? Double(zero)
        let daysLeft = getDaysLeft()
        let limit = getAverageSpending(budget: budget, spent: spend, daysLeft: daysLeft)
        
        if (showLimitLine) {
            ChartUtils.updateLimitLine(limitLine: limitLine,
                                       axis: uv_bar_chart.leftAxis,
                                       limit: limit,
                                       label: "\(Const.limitLineLabel) \(limit)",
                                       chart: uv_bar_chart)
        } else {
            uv_bar_chart.leftAxis.removeLimitLine(limitLine)
        }
    }
    
    func setLineChartValues(_ dataPoints: [Date], _ values: [Double]) {
        ChartUtils.switchView(fromView: uv_bar_chart, toView: uv_line_chart)
        let dataEntries = (zero..<dataPoints.count).map{ ChartDataEntry(x: Double($0), y: values[$0]) }
        
        if let set = uv_line_chart.data?.dataSets.first as? LineChartDataSet {
            set.replaceEntries(dataEntries)
            uv_line_chart.data?.notifyDataChanged()
            uv_line_chart.notifyDataSetChanged()
        } else {
            let chartDataSet = LineChartDataSet(entries: dataEntries, label: Const.lineLabel)
            let data = LineChartData(dataSet: chartDataSet)
            data.setValueFont(UIFont.chartFont)
            uv_line_chart.data = data
            uv_line_chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints.map{ Date().getXAxisFormatDate($0) })
            
            ChartUtils.setLineChartDataSetStyle(chartDataSet)
            ChartUtils.setYAxisMoneyFormatter(uv_line_chart)
            ChartUtils.setLegend(uv_line_chart.legend)
            
            guard let budgetText = tf_budget.text else { return }
            let spend = self.getTotalAmount(array: self.sumArray)
            let budget: Double = Double(budgetText) ?? Double(zero)
            let daysLeft = getDaysLeft()
            let limit = getAverageSpending(budget: budget, spent: spend, daysLeft: daysLeft)
            if (showLimitLine) {
                ChartUtils.updateLimitLine(limitLine: limitLine,
                                           axis: uv_line_chart.leftAxis, limit: limit,
                                           label: "\(Const.limitLineLabel): $\(limit)", chart: uv_line_chart)
            } else {
                uv_line_chart.leftAxis.removeLimitLine(limitLine)
            }
        }
    }
    
    func updateChartRecordArray(_ type: Enum.GraphType) {
        switch type {
        case .week: // accumulate spense for each day of the week
            updateChartRecordArray(lastNDays:Const.daysInAWeek, drawChartFunction: self.setBarChartValues)
        case .month: // accumulate spense for each day of the month
            updateChartRecordArray(lastNDays:Const.daysInAMonth, drawChartFunction: self.setLineChartValues)
        }
    }
    
    func updateChartRecordArray(lastNDays: Int, drawChartFunction: @escaping (_ date : [Date], _ values: [Double])  -> Void) {
        let dates = Date().getLastNDays(lastNDays)
        var chartValues: [Double] = Array(repeating: Double(zero), count: dates.count)
        for i in 0..<dates.count {
            let date = dates[i]
            ref.child(String("\(date)".prefix(10))).observe(.value, with: { (snapshot) in
                for record in snapshot.children.allObjects as! [DataSnapshot] {
                    let recordObject = record.value as? [String: AnyObject]
                    chartValues[i] += recordObject?[Const.amount] as! Double
                }
                drawChartFunction(dates, chartValues)
            })
        }
    }
}
