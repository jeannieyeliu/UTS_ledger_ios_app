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
    
    let string = Enum.StringList.self
    fileprivate weak var calendar: FSCalendar!
    
    var today = Date()
    var currentDate = String()
    var refDate: DatabaseReference!
    var recordArray = [Record]()
    var eventArray = [Event]()
    var sum = 0.0
    var isMonth = true
    
    @IBAction func btn_addRecord(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: string.addRecord.rawValue, sender: nil)
    }
    @IBOutlet weak var uv_calendar: UIView!
    @IBOutlet weak var tbl_records: UITableView!
    @IBOutlet weak var lb_listName: UILabel!
    @IBAction func btn_statistic(_ sender: Any) {
        performSegue(withIdentifier: string.showStat.rawValue, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refDate = Database.database().reference().child(string.root.rawValue).child(string.date.rawValue)
        setUpCalendar()
        currentDate = currentDate.isEmpty ? String("\(today)".prefix(10)) : currentDate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        calendar.select(getDate(dateString: currentDate), scrollToDate: true)
        loadRecordDate(date: currentDate)
        getEventNumber()
    }
    
    func loadRecordDate(date: String) {
        refDate.child(date).observe(.value, with: { (snapshot) in
            self.recordArray.removeAll()
            
            if snapshot.childrenCount > 0 {
                for record in snapshot.children.allObjects as! [DataSnapshot] {
                    let recordObject = record.value as? [String: AnyObject]
                    let amount = recordObject?[self.string.amount.rawValue]
                    let category = recordObject?[self.string.category.rawValue]
                    let note = recordObject?[self.string.note.rawValue]
                    
                    self.recordArray.append(Record(id: record.key, amount: amount as! Double, category: category as! String, note: note as! String))
                }
            }
            self.tbl_records.reloadData()
        })
    }
    
    func getEventNumber() {
        refDate.observe(.value, with: { (snapshot) in
            self.eventArray.removeAll()
            
            if snapshot.childrenCount > 0 {
                for event in snapshot.children.allObjects as! [DataSnapshot] {
                    let dateKey = event.key
                    let noOfEvent = event.children.allObjects.count
                    
                    self.eventArray.append(Event(date: dateKey, eventNumber: noOfEvent))
                }
            }
            self.calendar.reloadData()
        })
    }
    
    func setUpCalendar() {
        let calendar = FSCalendar(frame: CGRect(x: (uv_calendar.bounds.maxX / 2) - (uv_calendar.bounds.maxX - 40) / 2, y: 0, width: uv_calendar.bounds.maxX - 40, height: uv_calendar.bounds.maxY))
        
        calendar.dataSource = self
        calendar.delegate = self
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: string.calendar.rawValue)
        uv_calendar.addSubview(calendar)
        
        self.calendar = calendar
        
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
        calendar.appearance.headerDateFormat = string.dateFormat1.rawValue
        
        calendar.appearance.weekdayTextColor = UIColor.darkBlue
        calendar.appearance.headerTitleColor = UIColor.darkBlue
        calendar.appearance.selectionColor = UIColor.oceanBlue
        calendar.appearance.todayColor = UIColor.darkBlue
        calendar.appearance.todaySelectionColor = UIColor.oceanBlue
        
        calendar.appearance.titleFont = UIFont(name: string.chalkFont.rawValue, size: 20)
        calendar.appearance.weekdayFont = UIFont(name: string.chalkFont.rawValue, size: 17)
        calendar.appearance.headerTitleFont = UIFont(name: string.chalkFont.rawValue, size: 25)
    }
    
    // do preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == string.editExpense.rawValue || segue.identifier == string.addToPay.rawValue),
            let destination = segue.destination as? AddRecordTableViewController,
            let cellIndex = tbl_records.indexPathForSelectedRow?.row {
            destination.date = currentDate
            destination.amount = recordArray[cellIndex].amount
            destination.id = recordArray[cellIndex].id
            destination.imageName = recordArray[cellIndex].category
            destination.note = recordArray[cellIndex].note
            
        } else if segue.identifier == string.addRecord.rawValue,
            let destination = segue.destination as? AddRecordTableViewController {
            destination.date = currentDate
            destination.amount = Double(Int.max)
            destination.id = string.blank.rawValue
            destination.imageName = string.dafaultImg.rawValue
            destination.note = string.blank.rawValue
        }
    }
    
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

extension HomeViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordArray.count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell: ExpenseTableViewSection = tableView.dequeueReusableCell(withIdentifier: string.footer.rawValue) as! ExpenseTableViewSection
        cell.lb_totalAmount.text = String.init(format: string.dollar.rawValue, getTotalAmount()) //"\(string.dollar.rawValue)\(getTotalAmount())"
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ExpenseTableViewCell
        if getDate(dateString: currentDate) <= today {
            tableView.rowHeight = 70
            cell = tableView.dequeueReusableCell(withIdentifier: string.expense.rawValue, for: indexPath) as! ExpenseTableViewCell
            
        } else {
            tableView.rowHeight = 100
            cell = tableView.dequeueReusableCell(withIdentifier: string.toPay.rawValue, for: indexPath) as! ExpenseTableViewCell
            let countDown = getCountDown(from: String("\(today)".prefix(10)), to: currentDate)
            cell.lb_countDown.text = "\(countDown)"
            cell.setColor(day: countDown)
        }
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
            let alert = UIAlertController(title: "Delete", message: "Do you want to delete this record?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                let id = self.recordArray[indexPath.row].id
                self.refDate.child(self.currentDate).child(id).setValue(nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "calendarCell", for: date, at: position)
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let correctDate = getCorrectDate(forDate: date)
        var eventCounter = 0
        for event in eventArray {
            if event.date == correctDate {
                eventCounter = Int(event.eventNumber)
            }
        }
        return eventCounter
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let correctDate = getCorrectDate(forDate: date)
        return getEventColor(forDate: String(correctDate))
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        let correctDate = getCorrectDate(forDate: date)
        return getEventColor(forDate: String(correctDate))
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        currentDate = getCorrectDate(forDate: date)
        lb_listName.text = getDate(dateString: currentDate) <= today ? "Record List" : "To Pay List"
        loadRecordDate(date: currentDate)
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendar.frame = CGRect(origin: calendar.frame.origin, size: bounds.size)
    }
    
    func getEventColor(forDate: String) -> [UIColor] {
        let countDown = getCountDown(from: String("\(today)".prefix(10)), to: forDate)
        if (countDown <= 3) && (countDown > 0) && (getDate(dateString: forDate) > getDate(dateString: String("\(today)".prefix(10)))) {
            return [UIColor.red]
        }
        return [UIColor.oceanBlue]
    }
}
