//
//  ChartUtils.swift
//  MoMo
//
//  Created by 刘烨 on 28/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import UIKit
import Charts

// This extension is to support the charts
extension ChartUtils {
    
    // Change to another view
    static func switchView(fromView: BarLineChartViewBase, toView: BarLineChartViewBase) {
        fromView.data = nil
        fromView.alpha = 0.0
        toView.alpha = 1.0
    }
    
    static func setLegend(_ lengend: Legend) {
        lengend.horizontalAlignment = .left
        lengend.verticalAlignment = .bottom
        lengend.orientation = .horizontal
        lengend.drawInside = false
        lengend.form = .circle
        lengend.formSize = 5
        lengend.font = UIFont.chartFont
        lengend.xEntrySpace = 4
    }
    
    // set up the balloon pop up when clicked
    static func setMarker(chartView: BarLineChartViewBase, lastNDays: Int) {
        let marker = BalloonMarker(color: UIColor.darkBlue,
                                   font: UIFont.chartFont,
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                   chartXEntryLength: lastNDays)
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        chartView.marker = marker
    }
    
    
    static func updateLimitLine(limitLine: ChartLimitLine, axis: YAxis, limit: Double, label: String, chart: BarLineChartViewBase) {
        limitLine.limit = limit
        limitLine.label = label
        chart.leftAxis.removeLimitLine(limitLine)
        chart.leftAxis.addLimitLine(limitLine)
    }
    
    static func setChartViewStyle(limitLine: ChartLimitLine, chart: BarLineChartViewBase, showLimitLine: Bool) {
        // Set style for chart
        chart.rightAxis.labelFont = UIFont.chartFont
        chart.leftAxis.labelFont = UIFont.chartFont
        chart.xAxis.labelFont = UIFont.chartFont
        chart.chartDescription?.text = Const.blank
        chart.noDataText = Const.blank
        chart.xAxis.labelPosition = .bottom
        chart.leftAxis.axisMinimum = 0
        
        // Add a limit line
        limitLine.lineWidth = 2
        limitLine.lineDashLengths = [5, 5]
        limitLine.labelPosition = .topRight
        limitLine.valueFont = UIFont.chartFont
        limitLine.valueTextColor = .red
        if showLimitLine {
            chart.leftAxis.addLimitLine(limitLine)
        }
    }
    
    static func setYAxisMoneyFormatter(_ chart: BarLineChartViewBase) {
        let axisFormatter = NumberFormatter()
        axisFormatter.negativePrefix = Const.dollar
        axisFormatter.positivePrefix = Const.dollar
        chart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: axisFormatter)
        chart.rightAxis.valueFormatter = DefaultAxisValueFormatter(formatter: axisFormatter)
    }
    
    static func setLineChartDataSetStyle(_ chartDataSet: LineChartDataSet) {
        chartDataSet.drawValuesEnabled = false
        chartDataSet.circleRadius = 3
        chartDataSet.setColor(UIColor.oceanBlue)
        chartDataSet.setCircleColor(UIColor.oceanBlue)
    }
    
    static func setBarChartDataSetStyle(_ chartDataSet: BarChartDataSet) {
        chartDataSet.drawValuesEnabled = false
        let data = BarChartData(dataSet: chartDataSet)
        data.setValueFont(UIFont.chartFont)
    }
}
