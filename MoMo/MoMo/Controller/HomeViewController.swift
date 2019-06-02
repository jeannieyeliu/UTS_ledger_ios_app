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
    var today = Date()
    var currentDate = String()
    var refDate: DatabaseReference!
    var recordArray = [Record]()
    var eventArray = [Event]()
    var sum = Double()
    
    @IBOutlet weak var uv_calendar: UIView!
    @IBOutlet weak var tbl_records: UITableView!
    @IBOutlet weak var lb_listName: UILabel!
    
    @IBAction func btn_addRecord(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Const.addRecord, sender: nil)
    }
    
    @IBAction func btn_statistic(_ sender: Any) {
        performSegue(withIdentifier: Const.showStat, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.applicationIconBadgeNumber = 0
        refDate = Database.database().reference().child(Const.root).child(Const.date)
        setUpCalendar()
        currentDate = currentDate.isEmpty ? String("\(today)".prefix(10)) : currentDate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.applicationIconBadgeNumber = 0
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
                    let amount = recordObject?[Const.amount]
                    let category = recordObject?[Const.category]
                    let note = recordObject?[Const.note]
                    
                    self.recordArray.append(Record(id: record.key, amount: amount as! Double, category: category as! String, note: note as! String))
                }
            }
            self.recordArray.reverse()
            self.tbl_records.reloadData()
            self.cellAnimation()
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
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: Const.calendar)
        uv_calendar.addSubview(calendar)
        
        self.calendar = calendar
        calendar.firstWeekday = 2
        
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0;
        calendar.appearance.headerDateFormat = Const.dateFormat1
        
        calendar.appearance.weekdayTextColor = UIColor.darkBlue
        calendar.appearance.headerTitleColor = UIColor.darkBlue
        calendar.appearance.selectionColor = UIColor.oceanBlue
        calendar.appearance.todayColor = UIColor.darkBlue
        calendar.appearance.todaySelectionColor = UIColor.oceanBlue
        
        calendar.appearance.titleFont = UIFont(name: Const.chalkFont, size: 20)
        calendar.appearance.weekdayFont = UIFont(name: Const.chalkFont, size: 17)
        calendar.appearance.headerTitleFont = UIFont(name: Const.chalkFont, size: 25)
    }
    
    // do preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == Const.editExpense || segue.identifier == Const.addToPay),
            let destination = segue.destination as? AddRecordTableViewController,
            let cellIndex = tbl_records.indexPathForSelectedRow?.row {
            destination.date = currentDate
            destination.id = recordArray[cellIndex].id
            destination.note = recordArray[cellIndex].note
            destination.amount = recordArray[cellIndex].amount
            destination.imageName = recordArray[cellIndex].category
            
        } else if segue.identifier == Const.addRecord,
            let destination = segue.destination as? AddRecordTableViewController {
            destination.id = Const.blank
            destination.note = Const.blank
            destination.date = currentDate
            destination.amount = Double(Int.max)
            destination.imageName = Const.dafaultImg
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
        let cell: ExpenseTableViewSection = tableView.dequeueReusableCell(withIdentifier: Const.footer) as! ExpenseTableViewSection
        cell.lb_totalAmount.text = "\(Const.dollar)\(getTotalAmount())"
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ExpenseTableViewCell
        if getDate(dateString: currentDate) <= today {
            tableView.rowHeight = 70
            cell = tableView.dequeueReusableCell(withIdentifier: Const.expense, for: indexPath) as! ExpenseTableViewCell
            
        } else {
            tableView.rowHeight = 100
            cell = tableView.dequeueReusableCell(withIdentifier: Const.toPay, for: indexPath) as! ExpenseTableViewCell
            let countDown = getCountDown(from: String("\(today)".prefix(10)), to: currentDate)
            cell.lb_countDown.text = "\(countDown)"
            cell.setColor(day: countDown)
        }
        if recordArray.count > 0 {
            cell.iv_category.image = UIImage(named: recordArray[indexPath.row].category)
            cell.lb_amount.text = "\(Const.dollar)\(recordArray[indexPath.row].amount)"
            cell.lb_note.text = recordArray[indexPath.row].note
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            let alert = UIAlertController(title: Const.deleteTit, message: Const.deleteMes, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Const.yes, style: .default, handler: { action in
                let id = self.recordArray[indexPath.row].id
                self.refDate.child(self.currentDate).child(id).setValue(nil)
            }))
            alert.addAction(UIAlertAction(title: Const.cancel, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: Const.calendar, for: date, at: position)
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
        lb_listName.text = getDate(dateString: currentDate) <= today ? Const.recordList : Const.toPayList
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
    
    func cellAnimation() {
        let visibleCells = tbl_records.visibleCells
        var delayOffset: Double = 0.0
        
        for cell in visibleCells {
            cell.transform = CGAffineTransform(translationX: 0, y: tbl_records.frame.height)
        }
        
        for cell in visibleCells {
            UIView.animate(withDuration: 1,
                           delay: delayOffset * 0.05,
                           usingSpringWithDamping: 0.75,
                           initialSpringVelocity: 0,
                           options: .curveEaseInOut,
                           animations: {
                            cell.transform = CGAffineTransform.identity
            })
            delayOffset += 1
        }
    }
}
