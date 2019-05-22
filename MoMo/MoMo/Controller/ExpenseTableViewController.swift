//
//  ExpenseTableViewController.swift
//  MoMo
//
//  Created by BonnieLee on 17/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import UIKit

class ExpenseTableViewController: UITableViewController {

    var dateArray = [RecordDate]()
    var recordArray = [Record]()
    var totalAmount = [Double]()
    let today = Date()
    
    @IBAction func btn_add(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "Expense_Record", sender: nil)
    }
    
    @IBOutlet var tbl_expense_table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDateArray()
        tbl_expense_table.reloadData()
        //print(dateArray)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func initDateArray() {
        for counter in 1...2 {
            for r_counter in 1...2 {
                let record = Record(id: "\(counter)\(r_counter)", amount: Double(counter+r_counter), category: "Others", note: "This is note \(r_counter)")
                recordArray.append(record)
            }
            guard let lastDate = Calendar.current.date(byAdding: .day, value: -counter, to: today)
                else {return}
            let dateInString = "\(lastDate)".prefix(10)
            let date = RecordDate(date: String(dateInString), records: recordArray)
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
        let cell: ExpenseTableViewSection = tableView.dequeueReusableCell(withIdentifier: "ExpenseSection") as! ExpenseTableViewSection
        cell.lb_date.text = dateArray[section].date
        cell.lb_totalAmount.text = "$\(dateArray[section].getTotalAmount(recordArray: dateArray[section].records))"
        return cell.contentView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ExpenseTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath) as! ExpenseTableViewCell
        
        cell.lb_amount.text = "$\(dateArray[indexPath.section].records[indexPath.row].amount)"
        cell.lb_note.text = "\(dateArray[indexPath.section].records[indexPath.row].note), id: \(dateArray[indexPath.section].records[indexPath.row].id)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath)
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier:"addRecordSB")
        self.present(newViewController, animated: true, completion: nil)
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
