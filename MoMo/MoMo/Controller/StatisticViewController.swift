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
    var weekTitle = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    var monthTitle = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refDate = Database.database().reference().child("MoMo").child("Date")
        setupSegmentedControl()
        barChartView.chartDescription?.text = ""
        barChartView.noDataText = ""
        //showChart(type: .week)
        initChartViewStyle()
        
        let weekData = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0]
        updateChartRecordArray(.week)
        //setChartValues(dataPoints: weekTitle, values: weekData)
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
            let dataEntry = BarChartDataEntry(x: Double(i+1), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        if let set = barChartView.data?.dataSets.first as? BarChartDataSet {
            set.replaceEntries(dataEntries)
            barChartView.data?.notifyDataChanged()
            barChartView.notifyDataSetChanged()
        }else {
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Money spent")
            chartDataSet.colors = ChartColorTemplates.material()
            chartDataSet.drawValuesEnabled = true
            let data = BarChartData(dataSet: chartDataSet)
            data.setValueFont(UIFont(name: "Chalkboard SE", size: 10)!)
            //data.barWidth = 7.0 / Double(dataPoints.count) // 0.9
            barChartView.data = data
        }
    }
    
    func setLineChartValues(dataPoints: [Int], values: [Double]) {
        barChartView.data = nil
        lineChartView.alpha = 1.0
        barChartView.alpha = 0.0
        //var dataEntries: [ChartDataEntry] = []
        let dataEntries : [ChartDataEntry] = (0..<dataPoints.count).map{ (i) -> ChartDataEntry in
            return  ChartDataEntry(x: Double(i+1), y: values[i])
        }
        
//        for i in 0..<dataPoints.count {
//            let dataEntry = ChartDataEntry(x: Double(i+1), y: values[i])
//            dataEntries.append(dataEntry)
//        }
        
        if let set = lineChartView.data?.dataSets.first as? LineChartDataSet {
            set.replaceEntries(dataEntries)
            lineChartView.data?.notifyDataChanged()
            lineChartView.notifyDataSetChanged()
        }else {
            let chartDataSet = LineChartDataSet(entries: dataEntries, label: "Monthly Money spent")
            chartDataSet.colors = ChartColorTemplates.material()
            chartDataSet.drawValuesEnabled = false
            let data = LineChartData(dataSet: chartDataSet)
            data.setValueFont(UIFont(name: "Chalkboard SE", size: 10)!)
            
            lineChartView.data = data
        }
    }
    
    
    
    @IBAction func scDateRangeChange(_ sender: UISegmentedControl) {
        switch scDateRange.selectedSegmentIndex {
        case 0:
            updateChartRecordArray(.week)
        case 1:
            
            updateChartRecordArray(.month)
        case 2:
            let monthData:[Double] = [1,2,3,4,5,6,7,8,9,10,11,12]
            setBarChartValues(dataPoints: monthTitle, values: monthData)
            break;
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
 
                    var weekValues : [Double] = []
                    for i in 0...(self.weekTitle.count-1)  {
                        let title = self.weekTitle[i]
                        weekValues.append(self.barsDict[title] == nil ? 0: self.barsDict[title]!)
                    }
                    self.setBarChartValues(dataPoints: self.weekTitle, values: weekValues)
                    
                })
            }
            break
        case .month:
            //dates = getMonth()
            
            linesDict.removeAll()
            dates = getMonthTillToday()
            print(dates)
            let dayTitle : [Int] = dates.map{(date) -> Int in
                let dayName = subStr(str: "\(date)", from: 8, length: 2)
                let day =  Int(dayName)
                self.linesDict[day!] = 0.0
                return day!
            }
            print("dayTitle")
            print (dayTitle)
            
            for date in dates {
                let dateStr = String("\(date)".prefix(10))
                let dayName : String = subStr(str: "\(date)", from: 8, length: 2 )
                let day =  Int(dayName)
                
//                if self.linesDict[day] == nil{
//                    seylf.linesDict[dayName] = 0
//                }
                
                refDate.child(dateStr).observe(.value, with: { (snapshot) in
                    var dayTotal: Double = 0
                    self.barsDict[dayName] = 0
                    if snapshot.childrenCount > 0 {
                        for record in snapshot.children.allObjects as! [DataSnapshot] {
                            let recordObject = record.value as? [String: AnyObject]
                            let amount = recordObject?["amount"] as! Double
                            dayTotal += amount
                            print("\(dateStr),amount:\(amount), dayTotal: \(dayTotal)")
                        }
                    }
                    self.linesDict[day!] = self.linesDict[day!]! + dayTotal
                    
                    var dayValues : [Double] = [Double](repeating: 0, count: dayTitle.count)
                    for i in 0...(dates.count-1)  {
                        
                        dayValues[i] = self.linesDict[i] == nil ? 0 : self.linesDict[i]!
                        
                        //dayValues.append(self.barsDict[title] == nil ? 0: self.barsDict[title]!)
                    }
                    self.setLineChartValues(dataPoints: dayTitle, values: dayValues)
                    print("linesDict:")
                    print(self.linesDict)
                    print("lenth of dayValues: \(dayValues.count)")
                    print("lenth of dates: \(dates.count)")
                    print(dayValues)
                })
            }
            break
        case .all:
            //TODO
            dates = getMonth()
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
        guard let day = comp.day else {
            return []
        }
        return getDatesByRange(from: 2 - day, to: 1)
    }
    
    // give a range of days, from means how many days before today
    //to means how many days after today
    func getDatesByRange(from: Int, to: Int) -> [Date] {
        var comp = calendar.dateComponents([.year, .month, .day, .weekday], from: today)
        guard let day = comp.day else {
            return []
        }
        
        var dates: [Date] = []
        for index in from ... to {
            comp.day = day + index
            let date = calendar.date(from: comp)
            if let date = date {
                dates.append(date)
            }
        }
        return dates
    }
    
    func getDaysOfAMonth(year: Int, month: Int) -> Int {
        
        var compEnd = DateComponents()
        compEnd.year = year
        compEnd.month = month
        let date = calendar.date(from: compEnd)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        return numDays
    }
    
    
    func initChartViewStyle() {
        barChartView.rightAxis.labelFont = (UIFont(name: "Chalkboard SE", size: 10)!)
        barChartView.leftAxis.labelFont = (UIFont(name: "Chalkboard SE", size: 10)!)
    }
    
    func subStr(str: String, from: Int, length: Int) -> String {
        let start = str.index( str.startIndex, offsetBy: from)
        let end = str.index(start, offsetBy: length)
        let range = start..<end
        let mySubstring = str[range]
        return String(mySubstring)
    }
    
}
