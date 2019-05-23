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
    var currentDate = String()
    var refDate: DatabaseReference!
    var recordArray = [Record]()
    var sum = 0.0
    //let initData = InitData()
    
    @IBAction func btn_addRecord(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addRecordNav", sender: nil)
    }
    @IBOutlet weak var uv_calendar: UIView!
    @IBOutlet weak var tbl_records: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refDate = Database.database().reference().child("MoMo").child("Date")
        setUpCalendar()
        getEventNumber()
        //getRecordDate(date: "2019-05-22")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentDate = String("\(today)".prefix(10))
        loadRecordDate(date: currentDate)
    }
    
    func loadRecordDate(date: String) {
        refDate.child(date).observe(.value, with: { (snapshot) in
            self.recordArray.removeAll()
            
            if snapshot.childrenCount > 0 {
                for record in snapshot.children.allObjects as! [DataSnapshot] {
                    let recordObject = record.value as? [String: AnyObject]
                    let amount = recordObject?["amount"]
                    let category = recordObject?["category"]
                    let note = recordObject?["note"]
                    
                    self.recordArray.append(Record(id: record.key, amount: amount as! Double, category: category as! String, note: note as! String))
                }
            }
            self.tbl_records.reloadData()
        })
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
    func getTotalAmount() -> Double {
        var totalAmount = [Double]()
        for record in recordArray {
            totalAmount.append(record.amount)
        }
        return totalAmount.reduce(0, +)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refDate.removeAllObservers()
    }
}

extension HomeViewController: FSCalendarDelegate, FSCalendarDataSource, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordArray.count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell: ExpenseTableViewSection = tableView.dequeueReusableCell(withIdentifier: "footerCell") as! ExpenseTableViewSection
        cell.lb_totalAmount.text = "$\(getTotalAmount())"
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ExpenseTableViewCell = tableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath) as! ExpenseTableViewCell
        
        if recordArray.count > 0 {
            cell.iv_category.image = UIImage(named: recordArray[indexPath.row].category)
            cell.lb_amount.text = "$\(recordArray[indexPath.row].amount)"
            cell.lb_note.text = recordArray[indexPath.row].note
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            let id = recordArray[indexPath.row].id
            refDate.child(currentDate).child(id).setValue(nil)
        }
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "calendarCell", for: date, at: position)
        
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // the date is wrong, need to add one more day.
        let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        currentDate = String("\(nextDate)".prefix(10))
        loadRecordDate(date: currentDate)
    }
    
    func getEventNumber(){
        
    }
    
}
