//
//  CompleteViewController.swift
//  diabuddy
//
//  Created by Mat Schmid on 2018-04-28.
//  Copyright © 2018 Mat Schmid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

protocol CompleteDelegate: class {
    func didWantToDismiss()
}

class CompleteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var remindersTableView: UITableView!
    @IBOutlet weak var completeButton: UIButton!
    
    var reminders: [Reminder] = []
    
    var delegate: CompleteDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        remindersTableView.delegate = self
        remindersTableView.dataSource = self
        
        completeButton.layer.cornerRadius = 6
        view.backgroundColor = UIColor.white
        view.isOpaque = false
        
        fetchReminders { (reminderz) in
            self.reminders = reminderz!
            self.remindersTableView.reloadData()
        }
    }

    @IBAction func completeButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        delegate?.didWantToDismiss()
    }
    
    func getNextReminderString(reminders: [Reminder]) -> String {
        let currDate = Date()
        let hour = Calendar.current.component(.hour, from: currDate)
        let minutes = Calendar.current.component(.minute, from: currDate)
        let minutesSinceStartOfDay = (hour * 60) + minutes
        
        var nextReminder: Reminder?
        for reminder in reminders {
            if reminder.time > minutesSinceStartOfDay {
                nextReminder = reminder
                break
            }
        }
        
        var reminderString = ""
        if let nextReminder = nextReminder {
            reminderString = "\((nextReminder.title)) @ \(convertMinutesToTime(minutes: (nextReminder.time)))"
        }
        return reminderString
    }
    
    func fetchReminders(completion: @escaping (_ reminders: [Reminder]?) -> Void) {
        var reminders: [Reminder] = []
        let uid = Auth.auth().currentUser?.uid
        //let dateFormater = DateFormatter()
        //dateFormater.dateFormat = "M-dd-yyyy"
        //let todayDate = dateFormater.string(from: Date())
        let ref = Database.database().reference().child("users").child(uid!).child("insulinReminders")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let enumerator = snapshot.children
            while let child = enumerator.nextObject() as? DataSnapshot {
                guard let reminder = child.value as? NSDictionary else {
                    return
                }
                
                let title = reminder["title"]! as! String
                let time = reminder["time"]! as! Int
                let enabled = (reminder["enabled"]! as! Int == 1) ? true : false
                let completed = (reminder["completed"]! as! Int == 1) ? true : false
                
                if !completed {
                    let newReminder = Reminder(title: title, time: time, enabled: enabled, completed: completed)
                    reminders.append(newReminder)
                    reminders.sort(by: {$0.time < $1.time})
                }
            }
            completion(reminders)
        }, withCancel: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = reminders[indexPath.row].title
        cell.textLabel?.textColor = .black
        return cell
    }
    
}
