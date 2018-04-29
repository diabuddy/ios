//
//  NewReminderViewController.swift
//  diabuddy
//
//  Created by Mat Schmid on 2018-04-28.
//  Copyright © 2018 Mat Schmid. All rights reserved.
//

import UIKit
import TextFieldEffects
import FirebaseAuth
import FirebaseDatabase

class NewReminderViewController: UIViewController {

    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var titleTextField: IsaoTextField!
    
    var reminderTitle: String?
    var reminderData: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let title = reminderTitle, let date = reminderData {
            titleTextField.text = title
            timePicker.date = date
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save))
    }

    @objc func save() {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("users").child(uid!).child("insulinReminders").child(titleTextField.text!.lowercased())
        let reminder = Reminder(title: titleTextField.text!, time: convertTime(), enabled: true, completed: false)
        let event = ["title": reminder.title, "time": reminder.time, "enabled": reminder.enabled, "completed": reminder.completed] as [String : Any]
        ref.updateChildValues(event) { (err, ref) in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func convertTime() -> Int {
        let hour = Calendar.current.component(.hour, from: timePicker.date)
        let minutes = Calendar.current.component(.minute, from: timePicker.date)
        
        return (hour * 60) + minutes
    }
}
