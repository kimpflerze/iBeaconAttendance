//
//  ViewController.swift
//  iBeaconAttendance
//
//  Created by Zachary Kimpfler on 11/13/19.
//  Copyright © 2019 kimpflerze. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class EntryViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var authenticationOptionSegmentControl: UISegmentedControl!
    @IBOutlet weak var userTypeSegmentControl: UISegmentedControl!
    @IBOutlet weak var firstNameTextfield: UITextField!
    @IBOutlet weak var lastNameTextfield: UITextField!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var authenticateButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var nameStackView: UIStackView!
    @IBOutlet weak var emailStackView: UIStackView!
    
    var textFieldHeight: CGFloat = 0
    
    @IBAction func authenticateAction(_ sender: Any) {
        let username: String! = usernameTextfield.text
        let password: String! = passwordTextfield.text
        let firstName: String! = firstNameTextfield.text
        let lastName: String! = lastNameTextfield.text
        
        let credentialsFormatValid = UserLogin().validateInputCredential(email: username, password: password)
        let formattedCredentials = UserLogin().getFormattedCredentials(email: username, password: password)
        let formattedName = UserLogin().getFormattedName(first: firstName, last: lastName)
        
        //If let to allow use of optionals without coalescing or explicit un-wrapping.
        //Also check that the email credentials are not nil.
        if let tempEmail = formattedCredentials?["username"], let tempPassword = formattedCredentials?["password"], let fullName = formattedName["full"], credentialsFormatValid {
            //If the user is signing up.
            if(authenticationOptionSegmentControl.selectedSegmentIndex == 0) {
                let nameFormatValid = UserLogin().validateName(first: firstName, last: lastName)
                let userType = userTypeSegmentControl.selectedSegmentIndex
                
                //Sign up
                if(nameFormatValid) {
                    //Call to check if the user exists.
                    //If so, return.
                    //Else, createUser()
                    UserLogin().checkIfExistingUserAndCreateUser(email: tempEmail, password: tempPassword, fullName: fullName, type: userType)
                }
                else {
                    //Name format is invalid, present notice!
                    
                }

            }
            //If the user is signing in.
            else {
                //Sign in, get the result
                _ = UserLogin().login(withEmail: tempEmail, password: tempPassword)
            }
        }
    }
    
    @IBAction func authenticationOptionAction(_ sender: Any) {
        if(authenticationOptionSegmentControl.selectedSegmentIndex == 0) {
            if let constraint = (firstNameTextfield.constraints.filter{$0.firstAttribute == .height}.first) {
                constraint.constant = textFieldHeight
            }
            if let constraint = (lastNameTextfield.constraints.filter{$0.firstAttribute == .height}.first) {
                constraint.constant = textFieldHeight
            }
            if let constraint = (userTypeSegmentControl.constraints.filter{$0.firstAttribute == .height}.first) {
                constraint.constant = textFieldHeight
            }
            
            userTypeSegmentControl.isHidden = false
            
            let spacing = 16
            if let constraint = (nameStackView.constraints.filter{$0.firstAttribute == .height}.first) {
                constraint.constant = CGFloat((textFieldHeight * 2)) + CGFloat(spacing)
            }
            
            stackView.spacing = 16
            
            authenticateButton.setTitle("Sign Up", for: .normal)
        }
        else {
            if let constraint = (firstNameTextfield.constraints.filter{$0.firstAttribute == .height}.first) {
                constraint.constant = 0.0
            }
            if let constraint = (lastNameTextfield.constraints.filter{$0.firstAttribute == .height}.first) {
                constraint.constant = 0.0
            }
            if let constraint = (userTypeSegmentControl.constraints.filter{$0.firstAttribute == .height}.first) {
                constraint.constant = 0.0
            }
            
            userTypeSegmentControl.isHidden = true

            let spacing = 0
            if let constraint = (nameStackView.constraints.filter{$0.firstAttribute == .height}.first) {
                constraint.constant = CGFloat((textFieldHeight * 2)) + CGFloat(spacing)
            }
            
            stackView.spacing = 0
            
            authenticateButton.setTitle("Sign In", for: .normal)
        }
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        let email: String! = usernameTextfield.text
        let password = ""
        
        let credentialsFormatValid = UserLogin().validateInputCredential(email: email, password: password)
        let formattedCredentials = UserLogin().getFormattedCredentials(email: email, password: password)
        
        if let tempEmail = formattedCredentials?["email"], credentialsFormatValid {
            UserLogin().sendPasswordReset(withEmail: tempEmail)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let frameRect: CGRect = firstNameTextfield.frame;
        textFieldHeight = frameRect.size.height
        
        firstNameTextfield.delegate = self
        lastNameTextfield.delegate = self
        usernameTextfield.delegate = self
        passwordTextfield.delegate = self
        
        //Visual changes
        authenticateButton.layer.cornerRadius = 10
        authenticateButton.clipsToBounds = true
    }


}

