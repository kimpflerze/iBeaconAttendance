//
//  StudentLoginViewController.swift
//  iBeaconAttendance
//
//  Created by Zachary Kimpfler on 11/13/19.
//  Copyright © 2019 kimpflerze. All rights reserved.
//

import UIKit

class StudentLoginViewController: UIViewController, UITextFieldDelegate {
    
    enum AuthenticationOption {
        case signUp
        case signIn
    }
    
    var authenticationOption = AuthenticationOption.signUp

    @IBOutlet weak var signUpSignInSegmentControl: UISegmentedControl!
    @IBOutlet weak var studentUsernameTextfield: UITextField!
    @IBOutlet weak var studentPasswordTextfield: UITextField!
    @IBOutlet weak var studentLoginButton: UIButton!
    
    @IBAction func studentLoginAction(_ sender: Any) {
        let username: String! = studentUsernameTextfield.text
        let password: String! = studentPasswordTextfield.text
        
        
        let credentialsFormatValid = UserLogin().validateInputCredential(username: username, password: password)
        let formattedCredentials = UserLogin().getFormattedCredentials(username: username, password: password)
        let loginResult = UserLogin().login(username: username, password: password)
        
        /*
        if(authenticationOption == AuthenticationOption.signUp && credentialsFormatValid) {
            //Sign up, create new user.
            UserLogin().createUser(email: username, password: password)
        }
        else {
            //Sign in.
        }
        */
        
        
        if(credentialsFormatValid && loginResult) {
            //Successful login, segway.
            performSegue(withIdentifier: "studentLoginToStudentViewSegway", sender: self)
        }
        else {
            //Unsuccessful login, display error.
            clearInputFields()
            
            let invalidLoginAlert = UIAlertController(title: "Failed to Login", message: "The username or password entered was incorrect!", preferredStyle: .alert)
            
            invalidLoginAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(invalidLoginAlert, animated: true)
        }
        
    }
    
    @IBAction func signUpSignInAction(_ sender: Any) {
        //Set action result variable here!
        if(signUpSignInSegmentControl.selectedSegmentIndex == 0) {
            authenticationOption = AuthenticationOption.signUp
        }
        else {
            authenticationOption = AuthenticationOption.signIn
        }
    }
    
    func clearInputFields(){
        studentUsernameTextfield.text = ""
        studentPasswordTextfield.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.studentUsernameTextfield.delegate = self
        self.studentPasswordTextfield.delegate = self
        
        //Visual changes.
        studentLoginButton.layer.cornerRadius = 10
        studentLoginButton.clipsToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
