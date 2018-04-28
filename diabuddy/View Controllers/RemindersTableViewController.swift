//
//  RemindersTableViewController.swift
//  diabuddy
//
//  Created by Mat Schmid on 2018-04-28.
//  Copyright © 2018 Mat Schmid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RemindersTableViewController: UITableViewController {
    
    let cellReuse = "reminderCell"
    var reminders: [Reminder] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addReminderPrompt))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchReminders {
            self.tableView.reloadData()
        }
    }
    
    func fetchReminders(completion: @escaping () -> ()) {
        reminders = []
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
                
                let newReminder = Reminder(title: title, time: time, enabled: enabled)
                self.reminders.append(newReminder)
                self.reminders.sort(by: {$0.time < $1.time})
            }
            completion()
        }, withCancel: nil)
    }
    
    @objc func addReminderPrompt() {
        let newReminderVC = storyboard?.instantiateViewController(withIdentifier: "newReminder") as! NewReminderViewController
        navigationController?.pushViewController(newReminderVC, animated: true)
    }
    
    @objc func doneButtonTapped() {
        print("done")
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuse, for: indexPath) as! ReminderTableViewCell
        cell.formatWithReminder(reminder: reminders[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newReminderVC = storyboard?.instantiateViewController(withIdentifier: "newReminder") as! NewReminderViewController
        newReminderVC.reminderTitle = reminders[indexPath.row].title
        
        var components = DateComponents()
        components.hour = reminders[indexPath.row].time / 60
        components.minute = reminders[indexPath.row].time % 60
        
        let date = Calendar.current.date(from: components)
        newReminderVC.reminderData = date!
        
        navigationController?.pushViewController(newReminderVC, animated: true)
    }

}
