//
//  StatisticViewController.swift
//  MoMo
//
//  Created by BonnieLee on 20/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import UIKit
import UserNotifications
class StatisticViewController: UIViewController {

    @IBOutlet weak var tf_budget: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
       
        // Require Notification from system
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {
            didAllow, error in
            
        })
    }
    
    @IBAction func sendNoti(_ sender: Any) {
        let content = UNMutableNotificationContent()
        content.title = "You need to pay for electricity today!"
        content.subtitle = "You pay time is due now!"
        content.body = "This is notification body"
        content.badge = 1
        
        // Needs a trigger to trig notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "timeDone", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
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
