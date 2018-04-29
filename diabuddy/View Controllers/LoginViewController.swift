//
//  LoginViewController.swift
//  diabuddy
//
//  Created by Mat Schmid on 2018-04-28.
//  Copyright © 2018 Mat Schmid. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import TextFieldEffects

class LoginViewController: UIViewController {

    @IBOutlet weak var loginViewButton: UIButton!
    @IBOutlet weak var registerViewButton: UIButton!
    
    @IBOutlet weak var nameTextField: IsaoTextField!
    @IBOutlet weak var emailTextField: IsaoTextField!
    @IBOutlet weak var passwordTextField: IsaoTextField!
    @IBOutlet weak var confirmPasswordTextField: IsaoTextField!
    
    @IBOutlet weak var loginRegisterButton: UIButton!
    
    var loginViewSelected = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loginRegisterButton.layer.cornerRadius = 3
        presentSelectedView()
        hideKeyboardWhenTappedAround()
    }
    
    func presentSelectedView() {
        if loginViewSelected {
            loginViewButton.titleLabel?.attributedText = NSAttributedString(string: "Login", attributes: [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
            registerViewButton.titleLabel?.attributedText = nil
            registerViewButton.titleLabel?.text = "Register"
            nameTextField.alpha = 0
            confirmPasswordTextField.alpha = 0
        } else {
            registerViewButton.titleLabel?.attributedText = NSAttributedString(string: "Register", attributes: [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
            loginViewButton.titleLabel?.attributedText = nil
            loginViewButton.titleLabel?.text = "Login"
            nameTextField.alpha = 1
            confirmPasswordTextField.alpha = 1
        }
    }

    @IBAction func loginViewButtonTapped(_ sender: UIButton) {
        loginViewSelected = true
        presentSelectedView()
    }
    
    @IBAction func registerViewButtonTapped(_ sender: UIButton) {
        loginViewSelected = false
        presentSelectedView()
    }
    
    @IBAction func loginRegisterButtonTapped(_ sender: UIButton) {
        if loginViewSelected {
            // login
            guard let email = emailTextField.text, let password = passwordTextField.text else {
                print("Missing mandatory field(s)")
                return
            }
            
            Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
                if err != nil {
                    print(err.debugDescription)
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            // register
            guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
                print("Missing mandatory field(s)")
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { (user, err) in
                if err != nil {
                    print(err.debugDescription)
                    return
                }
                
                guard let uid = user?.uid else {
                    print("Authentication failed")
                    return
                }
                
                let values = ["name": name, "email": email]
                self.completeRegistrationWithUser(uid: uid, values: values as [String : AnyObject])
                
            }
        }
    }
    
    private func completeRegistrationWithUser(uid: String, values: [String : AnyObject]){
        let ref = Database.database().reference(fromURL: "https://diabuddy-80d53.firebaseio.com/")
        let userRef = ref.child("users").child(uid)
        
        userRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            let breakfast = Reminder(title: "Breakfast", time: 420, enabled: true, completed: false)
            let lunch = Reminder(title: "Lunch", time: 720, enabled: true, completed: false)
            let dinner = Reminder(title: "Dinner", time: 1020, enabled: true, completed: false)
            let bedtime = Reminder(title: "Bedtime", time: 1320, enabled: true, completed: false)
            let defaultReminders = [breakfast, lunch, dinner, bedtime]
            
            for reminder in defaultReminders {
                let remindersRef = userRef.child("insulinReminders").child(reminder.title.lowercased())
                
                let event = ["title": reminder.title, "time": reminder.time, "enabled": reminder.enabled, "completed": reminder.completed] as [String : Any]
                remindersRef.updateChildValues(event)
            }
            
            self.dismiss(animated: true, completion: nil)
            
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
