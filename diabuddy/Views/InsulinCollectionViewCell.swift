//
//  InsulinCollectionViewCell.swift
//  diabuddy
//
//  Created by Mat Schmid on 2018-04-28.
//  Copyright © 2018 Mat Schmid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

protocol InsulinCellDelegate: class {
    func didTapViewAll()
    func didTapComplete()
}

class InsulinCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nextReminderLabel: UILabel!
    @IBOutlet weak var allRemindersButton: UIButton!
    @IBOutlet weak var completeReminderButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    weak var delegate: InsulinCellDelegate?
    
    func formatCell() {
        layer.cornerRadius = 10
        allRemindersButton.layer.cornerRadius = 6
        completeReminderButton.layer.cornerRadius = 6
        progressBar.layer.cornerRadius = 4
        progressBar.layer.masksToBounds = true
        
        fetchReminders { (reminderz) in
            self.nextReminderLabel.text = self.getNextReminderString(reminders: reminderz!)
        }
    }
    
    @IBAction func viewAllRemindersTapped(_ sender: UIButton) {
        delegate?.didTapViewAll()
    }
    
    @IBAction func completeRemindersTapped(_ sender: UIButton) {
        delegate?.didTapComplete()
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
        
        var reminderString = "No upcoming reminders!"
        if let nextReminder = nextReminder {
            reminderString = "\((nextReminder.title)) @ \(convertMinutesToTime(minutes: (nextReminder.time)))"
        }
        return reminderString
    }
    
    func fetchReminders(completion: @escaping (_ reminders: [Reminder]?) -> Void) {
        var reminders: [Reminder] = []
        let uid = Auth.auth().currentUser?.uid
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
                
                let newReminder = Reminder(title: title, time: time, enabled: enabled, completed: completed)
                reminders.append(newReminder)
                reminders.sort(by: {$0.time < $1.time})
            }
            completion(reminders)
        }, withCancel: nil)
    }
    
}
