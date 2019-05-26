//
//  StatisticViewController.swift
//  MoMo
//
//  Created by BonnieLee on 20/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import UIKit
import SwiftCharts
import FirebaseDatabase
import Charts
class StatisticViewController: UIViewController {

    @IBOutlet weak var tf_budget: UITextField!
    //@IBOutlet weak var chartContentView: UIView!
    @IBOutlet weak var scDateRange: UISegmentedControl!
    @IBOutlet weak var outsideChartView: UIView!
    //@IBOutlet weak var chartContentView: BarChartView!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var lineChartView: LineChartView!
    
    var chartDataEntry = BarChartDataEntry()
    var chartDataEntries = [BarChartDataEntry]()
    
    let today = Date()
    let calendar = Calendar.current
    var barsDict: [String:Double] = [:]
    var linesDict: [Int:Double] = [:]
    var chartView: BarsChart!
    var refDate: DatabaseReference!
    var recordArray = [Record]()
    var weekTitle = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    var monthTitle = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let chartFont = UIFont(name: "Chalkboard SE", size: 10)!
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refDate = Database.database().reference().child("MoMo").child("Date")
        setupSegmentedControl()
        initChartViewStyle()
        updateChartRecordArray(.week)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setupSegmentedControl() {
        scDateRange.selectedSegmentIndex = 0
        
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
            leftAxisFormatter.negativePrefix = "$"
            leftAxisFormatter.positivePrefix = "$"
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
            let month = subStr(str: "\(today)", from: 5, length: 2)
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints.map{ (i) -> String in
                let day = i > 9 ? "\(i + 1)" : "0\(i+1)"
                return "\(day)/\(month)"})
            lineChartView.xAxis.labelFont = chartFont
            lineChartView.data = data
            let leftAxisFormatter = NumberFormatter()
            leftAxisFormatter.negativePrefix = "$"
            leftAxisFormatter.positivePrefix = "$"
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
    
    func updateChartRecordArray(_ type: GraphType) {
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
                
                refDate.child(dateStr).observe(.value, with: { (snapshot) in
                    var dayTotal: Double = 0
                    self.barsDict[weekName] = 0
                    if snapshot.childrenCount > 0 {
                        for record in snapshot.children.allObjects as! [DataSnapshot] {
                            let recordObject = record.value as? [String: AnyObject]
                            let amount = recordObject?["amount"] as! Double
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
                
                refDate.child(dateStr).observe(.value, with: { (snapshot) in
                    var dayTotal: Double = 0
                    self.barsDict[dayName] = 0
                    if snapshot.childrenCount > 0 {
                        for record in snapshot.children.allObjects as! [DataSnapshot] {
                            let recordObject = record.value as? [String: AnyObject]
                            let amount = recordObject?["amount"] as! Double
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
        return getDatesByRange(from: 1 - day, to: getDaysOfAMonth(year: year, month: month) - day)
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
    
    func getDaysOfAMonth(year: Int, month: Int) -> Int {
        var compEnd = DateComponents()
        compEnd.year = year
        compEnd.month = month
        let date = calendar.date(from: compEnd)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numOfDays = range.count
        return numOfDays
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
        barChartView.chartDescription?.text = ""
        barChartView.noDataText = ""
    }
    
}
