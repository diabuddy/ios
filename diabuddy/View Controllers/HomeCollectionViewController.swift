//
//  HomeCollectionViewController.swift
//  diabuddy
//
//  Created by Mat Schmid on 2018-04-28.
//  Copyright © 2018 Mat Schmid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Cheers

private let reuseIdentifier = "insulinCell"
private let calculateReuse = "calculateCell"
private let scoreReuse = "scoreCell"

class HomeCollectionViewController: UICollectionViewController {
    
    var isLoggedIn = false
    var completeVC: CompleteViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        hideKeyboardWhenTappedAround()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(handleLogout))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfUserIsLoggedIn()
        collectionView?.reloadData()
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            handleLogout()
        } else {
            isLoggedIn = true
        }
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        self.present(loginVC, animated: true, completion: nil)
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isLoggedIn ? 3 : 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! InsulinCollectionViewCell
            cell.delegate = self
            cell.formatCell()
            return cell
        } else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: calculateReuse, for: indexPath) as! CalculateCollectionViewCell
            cell.delegate = self
            cell.formatCell()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: scoreReuse, for: indexPath) as! ScoreCollectionViewCell
            cell.formatCell()
            return cell
        }
    }
}

extension HomeCollectionViewController: InsulinCellDelegate {
    func didTapViewAll() {
        let remindersViewController = self.storyboard?.instantiateViewController(withIdentifier: "reminders") as! UINavigationController
        self.present(remindersViewController, animated: true, completion: nil)
    }
    
    func didTapComplete() {
        completeVC = storyboard?.instantiateViewController(withIdentifier: "completeVC") as? CompleteViewController
        completeVC!.view.frame = CGRect(x: (UIScreen.main.bounds.size.width / 2) - 170, y: (UIScreen.main.bounds.size.height / 2) - 210, width: 340, height: 480)
        completeVC!.delegate = self
        completeVC!.view.layer.cornerRadius = 18
        completeVC!.view.layer.borderColor = UIColor.darkGray.cgColor
        completeVC!.view.layer.borderWidth = 2
        completeVC!.view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        view.addSubview(completeVC!.view)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.7, options: .allowUserInteraction, animations: {
            self.completeVC!.view.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }
}

extension HomeCollectionViewController: CalculateDelegate {
    func didRequestToCalculate(grams: Int) {
        let dosage = (grams % 15 == 0) ? grams / 15 : (grams / 15) + 1
        let alert = UIAlertController(title: "Calculate CHO Insulin Dose", message: "Assuming your Insulin CHO ratio is 1:15, your recommended dosage is \(dosage) units of rapid acting Insulin to cover the carbohydrates", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (alert) in
            let dateFormater = DateFormatter()
            dateFormater.dateFormat = "MM-dd-yyyy"
            let todayDate = dateFormater.string(from: Date())
            
            let uid = Auth.auth().currentUser?.uid
            let ref = Database.database().reference().child("users").child(uid!).child("history").child(todayDate).child(UUID().uuidString)
            let values = ["data": dosage, "eventType": "insulinUpdate", "timestamp": convertTime()] as [String : Any]
            ref.updateChildValues(values)
            
            // Create the view
            let cheerView = CheerView()
            cheerView.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
            self.view.addSubview(cheerView)
            
            // Configure
            cheerView.config.particle = .confetti
            // Start
            cheerView.start()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                cheerView.stop()
                self.collectionView?.reloadData()
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

extension HomeCollectionViewController: CompleteDelegate {
    func didWantToDismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .allowUserInteraction, animations: {
            self.completeVC!.view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }) { (completed) in
            self.completeVC!.view.removeFromSuperview()
            
        }
    }
    
    func didComplete() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .allowUserInteraction, animations: {
            self.completeVC!.view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }) { (completed) in
            self.completeVC!.view.removeFromSuperview()
            
            // Create the view
            let cheerView = CheerView()
            cheerView.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
            self.view.addSubview(cheerView)
            
            // Configure
            cheerView.config.particle = .confetti
            // Start
            cheerView.start()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                cheerView.stop()
                self.collectionView?.reloadData()
            })
        }
    }
}
