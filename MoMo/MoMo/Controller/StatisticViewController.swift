//
//  StatisticViewController.swift
//  MoMo
//
//  Created by BonnieLee on 20/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import UIKit
import SwiftCharts
class StatisticViewController: UIViewController {

    @IBOutlet weak var chartContentView: UIView!
    @IBOutlet weak var tf_budget: UITextField!
    var chartView: BarsChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let chartConfig = BarsChartConfig(valsAxisConfig:
            ChartAxisConfig(from: 1, to: 7, by: 1))
        
        let frame = CGRect(x:0, y: 300, width: chartContentView.frame.width, height: chartContentView.frame.height)
        
        let chart = BarsChart(frame: frame,
                              chartConfig: chartConfig, xTitle: "Week", yTitle: "Money Spent",
                              bars: [("Mon", 125),
                                     ("Tues", 250),
                                     ("Wed", 25.8),
                                     ("Thu", 215),
                                     ("Wed", 23),
                                     ("Sat", 300),
                                     ("Sun", 278),
                                    ],
                              color: UIColor.red, barWidth: (15))
        chartContentView.addSubview(chart.view)
        self.chartView = chart
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
