//
//  ToPayTableViewController.swift
//  MoMo
//
//  Created by BonnieLee on 17/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import UIKit

class ToPayTableViewController: UITableViewController {

    @IBOutlet weak var btn_addToPay: UIBarButtonItem!
    @IBOutlet var tbl_toPay: UITableView!
    
    var dateArray = [RecordDate]()
    var toPayArray = [Record]()
    let today = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDateArray()
        tbl_toPay.reloadData()
    }
    
    func initDateArray() {
        for counter in 1...2 {
            for r_counter in 1...2 {
                let record = Record(id: Int("\(counter)\(r_counter)") ?? 0, amount: Double(counter+r_counter), note: "This is note \(r_counter)")
                toPayArray.append(record)
            }
            guard let nextDate = Calendar.current.date(byAdding: .day, value: counter, to: today)
                else {return}
            let dateInString = "\(nextDate)".prefix(10)
            let date = RecordDate(date: String(dateInString), records: toPayArray)
            
            dateArray.append(date)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dateArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateArray[section].records.count
    }

    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell: ExpenseTableViewSection = tableView.dequeueReusableCell(withIdentifier: "ToPaySection") as! ExpenseTableViewSection
        cell.lb_date.text = dateArray[section].date
        cell.lb_totalAmount.text = "$\(dateArray[section].getTotalAmount(recordArray: dateArray[section].records))"
        return cell.contentView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ExpenseTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ToPayCell", for: indexPath) as! ExpenseTableViewCell
        
        cell.lb_amount.text = "$\(dateArray[indexPath.section].records[indexPath.row].amount)"
        cell.lb_note.text = "\(dateArray[indexPath.section].records[indexPath.row].note), id: \(dateArray[indexPath.section].records[indexPath.row].id)"

        let isoDate = dateArray[indexPath.section].date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        let date = dateFormatter.date(from:isoDate)!
        let countDown = Calendar.current.dateComponents([.day], from: today, to: date)
        if let number = Int("\(countDown)".components(separatedBy:CharacterSet.decimalDigits.inverted).joined()) {
            cell.lb_countDown.text = "\(number)"
        }
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
