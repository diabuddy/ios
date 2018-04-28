//
//  ReminderTableViewCell.swift
//  diabuddy
//
//  Created by Mat Schmid on 2018-04-28.
//  Copyright © 2018 Mat Schmid. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var enabledSwitch: UISwitch!
    
    func formatWithReminder(reminder: Reminder) {
        titleLabel.text = reminder.title
        timeLabel.text = convertMinutesToTime(minutes: reminder.time)
        enabledSwitch.isOn = reminder.enabled
    }
    
    func convertMinutesToTime(minutes: Int) -> String {
        var hours = minutes / 60
        let mins = (minutes % 60) < 10 ? "0\(minutes % 60)" : "\(minutes % 60)"
        var zone = "AM"
        if hours > 12 {
            hours = hours % 12
            zone = "PM"
        }
        return "\(hours):\(mins) \(zone)"
    }
}
