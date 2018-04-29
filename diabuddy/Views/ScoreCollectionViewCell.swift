//
//  ScoreCollectionViewCell.swift
//  diabuddy
//
//  Created by Mat Schmid on 2018-04-29.
//  Copyright © 2018 Mat Schmid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ScoreCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    func formatCell() {
        layer.cornerRadius = 10
        
        calculateScore { (score) in
            self.scoreLabel.text = "\(score)"
        }
    }
    
    func calculateScore(completion: @escaping (_ score: Int) -> ()) {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM-dd-yyyy"
        let todayDate = dateFormater.string(from: Date())
        
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("users").child(uid!).child("history").child(todayDate)
        
        ref.observe(.value, with: { (snapshot) in
            var score = 0
            let enumerator = snapshot.children
            while let _ = enumerator.nextObject() as? DataSnapshot {
                score += 500
            }
            completion(score)
        }, withCancel: nil)
    }
}
