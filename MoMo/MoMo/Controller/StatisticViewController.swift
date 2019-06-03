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

// This class is to show the statistic for the spending with the charts
class StatisticViewController: UIViewController {

    let calendar = Calendar.current
    let limitShape = CAShapeLayer()
    let progressShape = CAShapeLayer()
    
    var ref: DatabaseReference!
    var sumArray = [RecordSum]()
    var today = Date()
    var isMonth = true
    var limitLine: ChartLimitLine = ChartLimitLine(limit: Double(Const.zero), label: "\(Const.limitLineLabel): \(Const.dollar)\(Const.zero)")
    var showLimitLine = true
    
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

    // This function is to update the data when users change the budget value
    @IBAction func tf_budget_change(_ sender: UITextField) {
        let budgetText: String = sender.text ?? Const.zeroDouble
        let budget = Double(budgetText) ?? Double(Const.zero)
        UserDefaults.standard.set(budget, forKey: Const.budget)
        loadExpenseRecord(controller: self)
        changeLimitLine()
    }
    
    // This button is to navigate back to the home screen
    @IBAction func btn_back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Switch the statistic mode to monthly / weekly and save to default setting
    @IBAction func swt_mode(_ sender: UISwitch) {
        isMonth = isMonth ? false : true
        loadExpenseRecord(controller: self)
        changeLimitLine()
        UserDefaults.standard.set(isMonth, forKey: Const.isMonth)
    }
    
    // Update the limit line when user changes the segment
    @IBAction func sc_DateRangeChange(_ sender: UISegmentedControl) {
        changeLimitLine()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make the corner for the view
        uv_progress.layer.cornerRadius = 10;
        uv_progress.layer.masksToBounds = true;
        tf_budget.text = "\(UserDefaults.standard.double(forKey: Const.budget))"
        // Add done button to hide keyboard for the decimal number pad
        tf_budget.addDoneButtonToKeyboard(myAction: #selector(self.tf_budget.resignFirstResponder))
        
        ref = Database.database().reference().child(Const.root).child(Const.date)
        setUpCharts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        swt_mode_outlet.isOn = UserDefaults.standard.bool(forKey: Const.isMonth)
        isMonth = swt_mode_outlet.isOn
        loadExpenseRecord(controller: self)
        setUpCharts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Hide the keyboard when user touches the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tf_budget.resignFirstResponder()
    }
    
    // Setup the charts
    func setUpCharts() {
        ChartUtils.setChartViewStyle(limitLine: limitLine, chart: uv_bar_chart, showLimitLine: false)
        ChartUtils.setChartViewStyle(limitLine: limitLine, chart: uv_line_chart, showLimitLine: false)
        ChartUtils.setMarker(chartView: uv_bar_chart, lastNDays: Const.daysInAWeek)
        ChartUtils.setMarker(chartView: uv_line_chart, lastNDays: Const.daysInAMonth)
        updateChartRecordArray(Const.defaultChartType)
    }
    
    // Update label values with spending data, and draw a rectangle and a limit stroke on the
    // progress bar to show it
    func setTotalAmount (_ spent: Double) {
        guard let budgetText = tf_budget.text else { return }
        let budget = Double(budgetText) ?? Double(Const.zero)
        let daysLeft = getDaysLeft()
        let average = getAverageSpending(budget: budget, spent: spent, daysLeft: daysLeft)
        let limitPathPadding: CGFloat = 3
        
        lb_spent.text = "\(Const.dollar)\(spent)"
        lb_average.text = average == Double(Const.zero) ? Const.overused : "\(Const.dollar)\(average)"
        
        let limitX = getLimitX(budget: budget)
        let progressX = spent * Double(uv_progress.bounds.width) / budget
        
        let limitPath = UIBezierPath()
        limitPath.move(to: CGPoint(x: limitX, y: limitPathPadding))
        limitPath.addLine(to: CGPoint(x: limitX, y: uv_progress.bounds.maxY - limitPathPadding))
        
        limitShape.path = limitPath.cgPath
        limitShape.strokeColor = UIColor.lightBlue.cgColor
        limitShape.lineWidth = 3.5
        
        progressShape.path = UIBezierPath(rect: CGRect(x: CGFloat(Const.zero),
                                                       y: CGFloat(Const.zero),
                                                       width: CGFloat(progressX),
                                                       height: uv_progress.bounds.maxY)).cgPath
        
        progressShape.fillColor = getProgressColor(limit: Double(limitX), progress: progressX).cgColor
        
        uv_progress.layer.addSublayer(progressShape)
        uv_progress.layer.addSublayer(limitShape)
    }
    
    // Get the color based on the spending status (e.g. in control -> blue, exceed -> red)
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
    
    // Get the x location for the limit stroke
    func getLimitX(budget: Double) -> CGFloat {
        let noOfDays = isMonth ? getNumberOfDaysInAMonth() : 7
        var daysPassed = isMonth ? getDaysPassedMonth() : getDaysPassedWeek()
        daysPassed = daysPassed == Const.zero ? 1 : daysPassed
        let shouldSpend = budget / Double(noOfDays) * Double(daysPassed)
        
        return CGFloat(shouldSpend * Double(uv_progress.bounds.width) / budget)
    }
    
    // Get the number of days left by week or by month
    func getDaysLeft() -> Int {
        var noOfDays = Const.zero
        var daysPassed = Const.zero
        
        if isMonth {
            noOfDays = getNumberOfDaysInAMonth()
            daysPassed = getDaysPassedMonth()
        } else {
            noOfDays = Const.daysInAWeek
            daysPassed = getDaysPassedWeek()
        }
        return  noOfDays - daysPassed
    }
    
    // Get the average spending by calculating the budget, spent and daysLeft values
    func getAverageSpending(budget: Double, spent: Double, daysLeft: Int) -> Double {
        let average = round((budget - spent) / Double(daysLeft) * 100) / 100
        return average > Double(Const.zero) ? average : Double(Const.zero)
    }
    
    // Retrieve the data from Firebase to get the total spending amount and
    // pass the data to the callback function
    func loadExpenseRecord (controller: StatisticViewController) {
        ref.observe(.value, with: { (snapshot) in
            self.sumArray.removeAll()
            var systemCalendar = Int()
            var recordCalendar = Int()
            
            if snapshot.childrenCount > Const.zero {
                for record in snapshot.children.allObjects as! [DataSnapshot] {
                    systemCalendar = self.isMonth
                        ? Date().getCurrentMonth(from: self.today)
                        : Date().getCurrentWeek(from: self.today)
                    recordCalendar = self.isMonth
                        ? Date().getCurrentMonth(from: self.getDate(dateString: record.key))
                        : Date().getCurrentWeek(from: self.getDate(dateString: record.key))
                    
                    if systemCalendar == recordCalendar
                        && Date().isLessThanToday(
                            today: self.today,
                            and: self.getDate(dateString: record.key)) {
                        
                        for id in record.children.allObjects as! [DataSnapshot] {
                            let object = id.value as? [String: AnyObject]
                            let amount = object?[Const.amount]
                            self.sumArray.append(RecordSum(amount: amount as! Double))
                        }
                    }
                }
                controller.setTotalAmount(self.getTotalAmount(array: self.sumArray))
                self.changeLimitLine()
            }
        })
    }
    
    // Calculate the sum of an attribute inside the array
    func getTotalAmount(array: [RecordSum]) -> Double {
        let totalAmount: [Double] = array.map { amount in amount.amount }
        return round(totalAmount.reduce(0, +) * 100 ) / 100
    }
    
    // Modify the limit line based on the current mode
    // (e.g. weekly mode -> display / hide limit line in week / month chart)
    func changeLimitLine() {
        var type: Enum.GraphType = .week
        var chart: BarLineChartViewBase = uv_bar_chart
        switch sc_DateRange.selectedSegmentIndex {
            case 0:
                type = .week
                chart = uv_bar_chart
                showLimitLine = swt_mode_outlet.isOn ? false : true
            case 1:
                type = .month
                chart = uv_line_chart
                showLimitLine = swt_mode_outlet.isOn ? true : false
            default:
                fatalError()
        }
        chart.data = nil
        updateChartRecordArray(type)
    }
    
    // This function is to set up the bar chart values
    func setBarChartValues(_ dataPoints: [Date], _ values: [Double]) {
        ChartUtils.switchView(fromView: uv_line_chart , toView: uv_bar_chart)
        let dataEntries: [BarChartDataEntry] =
            (Const.zero ..< dataPoints.count).map{ BarChartDataEntry(x: Double($0), y: values[$0]) }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: Const.barLabel)
        chartDataSet.setColor(UIColor.darkBlue)
        chartDataSet.colors = [UIColor.darkBlue]
        
        let data = BarChartData(dataSet: chartDataSet)
        data.setValueFont(UIFont.chartFont)
        uv_bar_chart.xAxis.valueFormatter =
            IndexAxisValueFormatter(values: dataPoints.map{ Date().getWeekNameFromDate($0) })
        uv_bar_chart.data = data
        ChartUtils.setBarChartDataSetStyle(chartDataSet)
        ChartUtils.setYAxisMoneyFormatter(uv_bar_chart)
        ChartUtils.setLegend(uv_bar_chart.legend)
        
        let limit = getLimitValue()
        
        if showLimitLine {
            ChartUtils.updateLimitLine(limitLine: limitLine,
                                       axis: uv_bar_chart.leftAxis,
                                       limit: limit,
                                       label: "\(Const.limitLineLabel): \(Const.dollar)\(limit)",
                                       chart: uv_bar_chart)
        } else {
            uv_bar_chart.leftAxis.removeLimitLine(limitLine)
        }
    }
    
    // This function is to set up the line chart values
    func setLineChartValues(_ dataPoints: [Date], _ values: [Double]) {
        ChartUtils.switchView(fromView: uv_bar_chart, toView: uv_line_chart)
        let dataEntries = (Const.zero ..< dataPoints.count).map{ ChartDataEntry(x: Double($0), y: values[$0]) }
        
        if let set = uv_line_chart.data?.dataSets.first as? LineChartDataSet {
            set.replaceEntries(dataEntries)
            uv_line_chart.data?.notifyDataChanged()
            uv_line_chart.notifyDataSetChanged()
            
        } else {
            let chartDataSet = LineChartDataSet(entries: dataEntries, label: Const.lineLabel)
            let data = LineChartData(dataSet: chartDataSet)
            data.setValueFont(UIFont.chartFont)
            uv_line_chart.data = data
            uv_line_chart.xAxis.valueFormatter =
                IndexAxisValueFormatter(values: dataPoints.map{ Date().getXAxisFormatDate($0) })
            
            ChartUtils.setLineChartDataSetStyle(chartDataSet)
            ChartUtils.setYAxisMoneyFormatter(uv_line_chart)
            ChartUtils.setLegend(uv_line_chart.legend)
            
            let limit = getLimitValue()
            if showLimitLine {
                ChartUtils.updateLimitLine(limitLine: limitLine,
                                           axis: uv_line_chart.leftAxis,
                                           limit: limit,
                                           label: "\(Const.limitLineLabel): \(Const.dollar)\(limit)",
                                           chart: uv_line_chart)
            } else {
                uv_line_chart.leftAxis.removeLimitLine(limitLine)
            }
        }
    }
    
    // Get the limit value for the charts
    func getLimitValue() -> Double {
        guard let budgetText = tf_budget.text else { return Double(Const.zero) }
        let spend = self.getTotalAmount(array: self.sumArray)
        let budget: Double = Double(budgetText) ?? Double(Const.zero)
        let daysLeft = getDaysLeft()
        return getAverageSpending(budget: budget, spent: spend, daysLeft: daysLeft)
    }
    
    // Get the sum of spending amount for each day of week / month
    func updateChartRecordArray(_ type: Enum.GraphType) {
        switch type {
        case .week:
            updateChartRecordArray(lastNDays: Const.daysInAWeek, drawChartFunction: self.setBarChartValues)
        case .month:
            updateChartRecordArray(lastNDays: Const.daysInAMonth, drawChartFunction: self.setLineChartValues)
        }
    }
    
    // Retrive the data from Firebase for the charts
    func updateChartRecordArray(lastNDays: Int, drawChartFunction: @escaping (_ date : [Date], _ values: [Double])  -> Void) {
        let dates = Date().getLastNDays(lastNDays)
        var chartValues: [Double] = Array(repeating: Double(Const.zero), count: dates.count)
        for index in Const.zero ..< dates.count {
            let date = dates[index]
            ref.child(date.getShortDate()).observe(.value, with: { (snapshot) in
                for record in snapshot.children.allObjects as! [DataSnapshot] {
                    let recordObject = record.value as? [String: AnyObject]
                    chartValues[index] += recordObject?[Const.amount] as! Double
                }
                drawChartFunction(dates, chartValues)
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
    }
}
