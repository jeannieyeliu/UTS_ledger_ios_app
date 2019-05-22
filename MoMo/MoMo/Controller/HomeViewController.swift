//
//  HomeViewController.swift
//  MoMo
//
//  Created by BonnieLee on 21/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import UIKit
import FSCalendar
import FirebaseDatabase

class HomeViewController: UIViewController {
    
    fileprivate weak var calendar: FSCalendar!
    
    let today = Date()
    var ref: DatabaseReference!
    
    @IBAction func btn_addRecord(_ sender: UIBarButtonItem) {
    }
    @IBOutlet weak var uv_calendar: UIView!
    @IBOutlet weak var tbl_records: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        setUpCalendar()
    }
    
    func setUpCalendar() {
        let calendar = FSCalendar(frame: CGRect(x: (uv_calendar.bounds.maxX / 2) - (uv_calendar.bounds.maxX - 40) / 2, y: 0, width: uv_calendar.bounds.maxX - 40, height: uv_calendar.bounds.maxY))
        
        calendar.dataSource = self
        calendar.delegate = self
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "calendarCell")
        uv_calendar.addSubview(calendar)
        
        self.calendar = calendar
        
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
        calendar.appearance.headerDateFormat = "MMM yy"
        
        calendar.appearance.weekdayTextColor = UIColor(red:0.00, green:0.33, blue:0.58, alpha:1.0)
        calendar.appearance.headerTitleColor = UIColor(red:0.00, green:0.33, blue:0.58, alpha:1.0)
        calendar.appearance.eventDefaultColor = UIColor(red:0.00, green:0.50, blue:0.76, alpha:1.0)
        calendar.appearance.selectionColor = UIColor(red:0.00, green:0.50, blue:0.76, alpha:1.0)
        calendar.appearance.todayColor = UIColor(red:0.00, green:0.33, blue:0.58, alpha:1.0)
        calendar.appearance.todaySelectionColor = UIColor(red:0.00, green:0.50, blue:0.76, alpha:1.0)
        
        calendar.appearance.titleFont = UIFont(name: "Chalkboard SE", size: 20)
        calendar.appearance.weekdayFont = UIFont(name: "Chalkboard SE", size: 17)
        calendar.appearance.headerTitleFont = UIFont(name: "Chalkboard SE", size: 25)
        
        calendar.setCurrentPage(Date(), animated: true)
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

extension HomeViewController: FSCalendarDelegate, FSCalendarDataSource, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ExpenseTableViewCell = tableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath) as! ExpenseTableViewCell
        return cell;
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "calendarCell", for: date, at: position)
        
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if (date == today) {
            return 2
        } else {
            return 1
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // the date is wrong, need to add one more day.
    }
}
