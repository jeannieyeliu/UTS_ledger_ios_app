//
//  AddRecordTableViewController.swift
//  MoMo
//
//  Created by BonnieLee on 19/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import UIKit
import FirebaseDatabase
import UserNotifications

// This class is to add a new record with the amount, category, date and note
class AddRecordTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate, UITextViewDelegate {
 
    var refDate: DatabaseReference!
    var refCategory: DatabaseReference!
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
    
    // This button is to navigate back to the home screen
    @IBAction func btn_cancel(_ sender: Any) {
        performSegue(withIdentifier: Const.recordHome, sender: nil)
    }
    
    // Update data (if the ID is passed from the home screen)
    // or add new data (if ID is empty) to the Firebase
    @IBAction func btn_save(_ sender: UIBarButtonItem) {
        guard let amountText = tf_amount.text else { return; }
        amount = Double(amountText) ?? Double(Const.zero)
        note = tv_note.text ?? Const.blank
        let correctDate = Calendar.current.date(byAdding: .day, value: 1, to: dp_date_outlet.date)!
        let dateString = correctDate.getShortDate()
        
        if id != Const.blank {
            // If the date passed is different from the date in the date picker, remove data from Firebase
            if date != dateString {
                refDate.child(date).child(id).setValue(nil)
            }
            // Add new data with the new date
            date = dateString
            refDate.child(date).child(id).setValue([Const.amount: amount, Const.category: imageName, Const.note: note])
        } else {
            date = dateString
            addRecord()
        }
        sendNotification(note: note, amount: amount, date: dateString)
        performSegue(withIdentifier: Const.recordHome, sender: nil)
    }
    
    // Add new data to Firebase
    func addRecord() {
        let record = [Const.amount: amount as Double,
                      Const.category: imageName as String,
                      Const.note: note as String] as [String : Any]
        refDate.child(date).childByAutoId().setValue(record)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refDate = Database.database().reference().child(Const.root).child(Const.date)
        refCategory = Database.database().reference().child(Const.root).child(Const.cate)
        getCategoryData()
        collv_category.allowsMultipleSelection = false
        tf_amount.text = amount == Double(Int.max) ? Const.blank : "\(amount)"
        tv_note.text = note
        
        // Update the date picker with the date passed from the home screen which user
        // chooses to add new record
        if date != Const.blank {
            let dateToSet = getDate(dateString: date)
            dp_date_outlet.setDate(dateToSet, animated: true)
        }
        
        self.hideKeyboardWhenTappedAround()
        tf_amount.delegate = self
        tv_note.delegate = self
        
        // Add done button to hide keyboard for the decimal number pad
        tf_amount.addDoneButtonToKeyboard(myAction: #selector(self.tf_amount.resignFirstResponder))
    }
    
    // Retrieve the data for the category from Firebase and update the collection view
    func getCategoryData() {
        refCategory.observeSingleEvent(of: .value, with: { (snapshot) in
            if let category = snapshot.children.allObjects as? [DataSnapshot] {
                for child in category {
                    
                    let key = child.key as String
                    let id = snapshot.childSnapshot(forPath: "\(key)\(Const.cateID)").value
                    let description = snapshot.childSnapshot(forPath: "\(key)\(Const.cateDesc)").value
                    let image = snapshot.childSnapshot(forPath: "\(key)\(Const.cateImg)").value
                    
                    self.categoryArray.append(Category(id: id as! String, description: description as! String, image: image as! String))
                    
                    if self.categoryArray.count > Const.zero {
                        let indexArray = self.categoryArray.indices.filter {
                            self.categoryArray[$0].image.localizedCaseInsensitiveContains(self.imageName)
                        }
                        if indexArray.count > Const.zero {
                            self.categoryIndex = indexArray[Const.zero]
                        }
                    }
                    self.collv_category.reloadData()
                }
            }
        })
    }
    
    // This function is to hide the key board when user hits return in text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tf_amount.resignFirstResponder()
        return true
    }
    
    // This function is to hide the key board when user hits return in text view
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == Const.newLine {
            tv_note.resignFirstResponder()
            return false
        }
        return true
    }
    
    // Do preparation before moving to another view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Const.recordHome,
            let destination = segue.destination as? HomeViewController {
            destination.currentDate = date
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CategoryCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: Const.categoryC, for: indexPath) as! CategoryCollectionViewCell
        if categoryArray.count > Const.zero {
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
        cell.layer.borderWidth = CGFloat(Const.zero)
        cell.layer.borderColor = nil
        lb_categoryDesc.text = Const.blank
        imageName = categoryArray[12].image
    }
    
    // Call the notification when user add a record with the countdown = 1
    func sendNotification(note: String, amount: Double, date: String) {
        let today = Date()
        
        if getCountDown(from: today.getShortDate(), to: date) == 1 {
            let content = UNMutableNotificationContent()
            content.title = Const.noti_title
            content.subtitle = note.isEmpty ? Const.blank : "\(Const.noti_subtitle)\(note)"
            content.body = "\(Const.noti_body)\(Const.dollar)\(amount)"
            content.badge = 1

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: "\(note)\(amount)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refDate.removeAllObservers()
        refCategory.removeAllObservers()
    }
}
