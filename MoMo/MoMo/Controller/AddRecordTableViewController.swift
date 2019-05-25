//
//  AddRecordTableViewController.swift
//  MoMo
//
//  Created by BonnieLee on 19/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddRecordTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource  {
    
    var ref: DatabaseReference!
    var categoryArray = [Category]()
    var date = String()
    var amount = Double()
    var note = String()
    var id = String()
    var imageName = String()
    var categoryIndex = Int()
    
    @IBOutlet weak var ai_spinner: UIActivityIndicatorView!
    @IBOutlet weak var lb_categoryDesc: UILabel!
    @IBOutlet weak var tf_amount: UITextField!
    @IBOutlet weak var tv_note: UITextView!
    @IBOutlet weak var collv_category: UICollectionView!
    @IBOutlet weak var dp_date_outlet: UIDatePicker!
    
    @IBAction func btn_cancel(_ sender: Any) {
        performSegue(withIdentifier: "recordToHomeNav", sender: nil)
    }
    
    @IBAction func btn_save(_ sender: UIBarButtonItem) {
        guard let amountText = tf_amount.text else { return; }
        amount = Double(amountText) ?? 0.0
        note = tv_note.text ?? ""
        let correctDate = Calendar.current.date(byAdding: .day, value: 1, to: dp_date_outlet.date)!
        let dateString = String("\(correctDate)".prefix(10))
        
        if id != "" {
            if date != dateString {
                ref.child("MoMo").child("Date").child(date).child(id).setValue(nil)
            }
            date = dateString
            ref.child("MoMo").child("Date").child(date).child(id).setValue(["amount": amount, "category": imageName, "note": note])
        } else {
            date = dateString
            addRecord()
        }
        performSegue(withIdentifier: "recordToHomeNav", sender: nil)
    }
    
    func addRecord() {
        let record = ["amount": amount as Double, "category": imageName as String, "note": note as String] as [String : Any]
        ref.child("MoMo").child("Date").child(date).childByAutoId().setValue(record)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        getCategoryData()
        collv_category.allowsMultipleSelection = false
        tf_amount.text = amount == Double(Int.max) ? "" : "\(amount)"
        tv_note.text = note
        
        if date != "" {
            let dateToSet = getDate(dateString: date)
            dp_date_outlet.setDate(dateToSet, animated: true)
        }
    }
    
    func getCategoryData() {
        ref.child("MoMo").child("Category").observeSingleEvent(of: .value, with: { (snapshot) in
            if let category = snapshot.children.allObjects as? [DataSnapshot] {
                for child in category {
                    
                    let key = child.key as String
                    let id = snapshot.childSnapshot(forPath: "\(key)/id").value
                    let description = snapshot.childSnapshot(forPath: "\(key)/recordTypeDesc").value
                    let image = snapshot.childSnapshot(forPath: "\(key)/recordTypeImg").value

                    self.categoryArray.append(Category(id: id as! String, description: description as! String, image: image as! String))
                    
                    if self.categoryArray.count > 0 {
                        let indexArray = self.categoryArray.indices.filter {
                            self.categoryArray[$0].image.localizedCaseInsensitiveContains(self.imageName)
                        }
                        if indexArray.count > 0 {
                            self.categoryIndex = indexArray[0]
                        }
                    }
                    self.collv_category.reloadData()
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recordToHomeNav",
            let destination = segue.destination as? HomeViewController {
            destination.currentDate = date
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CategoryCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCollectionViewCell
        if categoryArray.count > 0 {
            ai_spinner.isHidden = true
            let categoryImg = categoryArray[indexPath.row].image
            cell.iv_category.image = UIImage(named: categoryImg)
        } else {
            ai_spinner.isHidden = false
        }
        
        if indexPath.row == categoryIndex {
            cell.layer.borderWidth = 2
            cell.layer.cornerRadius = 10
            cell.layer.borderColor = lb_categoryDesc.textColor.cgColor
            lb_categoryDesc.text = categoryArray[indexPath.row].description
            imageName = categoryArray[indexPath.row].image
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)!
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = lb_categoryDesc.textColor.cgColor
        lb_categoryDesc.text = categoryArray[indexPath.row].description
        imageName = categoryArray[indexPath.row].image
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)!
        cell.layer.borderWidth = 0
        cell.layer.borderColor = nil
        lb_categoryDesc.text = ""
        imageName = categoryArray[12].image
    }
    
    func getDate(dateString: String, format: String = "yyyy-MM-dd") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: dateString)!
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return date
    }
}
