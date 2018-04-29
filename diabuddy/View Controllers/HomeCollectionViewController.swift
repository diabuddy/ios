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

class HomeCollectionViewController: UICollectionViewController {
    
    var isLoggedIn = false
    var completeVC: CompleteViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        
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
        return isLoggedIn ? 1 : 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! InsulinCollectionViewCell
        cell.delegate = self
        cell.formatCell()
        return cell
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
