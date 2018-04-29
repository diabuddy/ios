//
//  CalculateCollectionViewCell.swift
//  diabuddy
//
//  Created by Mat Schmid on 2018-04-29.
//  Copyright © 2018 Mat Schmid. All rights reserved.
//

import UIKit
import TextFieldEffects

protocol CalculateDelegate: class {
    func didRequestToCalculate(grams: Int)
}

class CalculateCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var levelTextField: IsaoTextField!
    @IBOutlet weak var completeButton: UIButton!
    
    var delegate: CalculateDelegate?
    
    func formatCell() {
        layer.cornerRadius = 10
        completeButton.layer.cornerRadius = 6
    }
    
    @IBAction func completeButtonTapped(_ sender: UIButton) {
        guard let grams = Int(levelTextField.text!) else {
            return
        }
        delegate?.didRequestToCalculate(grams: grams)
        levelTextField.text = nil
    }
    
}
