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

class StatisticViewController: UIViewController {

    @IBOutlet weak var tf_budget: UITextField!
    @IBOutlet weak var chartContentView: UIView!
    @IBOutlet weak var scDateRange: UISegmentedControl!
    var chartView: BarsChart!
    var refDate: DatabaseReference!
    var recordArray = [Record]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refDate = Database.database().reference().child("MoMo").child("Date")
        setupSegmentedControl()
        showChart()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setupSegmentedControl() {
        let items = ["Last Week","This Week", "Next Week"]
        scDateRange.selectedSegmentIndex = 1
        
    }
    
    @IBAction func scDateRangeChange(_ sender: UISegmentedControl) {
    }
    func showChart(){
        let chartConfig = BarsChartConfig(valsAxisConfig:
            ChartAxisConfig(from: 0, to: 310, by: 50))
        
        let frame = CGRect(x:0, y: 0, width: chartContentView.frame.width, height: chartContentView.frame.height)
        
        let chart = BarsChart(frame: frame,
                              chartConfig: chartConfig, xTitle: "Last 7 Days", yTitle: "Money Spent",
                              bars: [("Mon", 125),
                                     ("Tues", 250),
                                     ("Wed", 25.8),
                                     ("Thu", 215),
                                     ("Wed", 23),
                                     ("Sat", 210),
                                     ("Sun", 218),
            ],
                              color: UIColor.red, barWidth: (15))
        chartContentView.addSubview(chart.view)
        self.chartView = chart
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
