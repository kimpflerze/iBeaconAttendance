//
//  ProfessorLoginViewController.swift
//  iBeaconAttendance
//
//  Created by Zachary Kimpfler on 11/13/19.
//  Copyright © 2019 kimpflerze. All rights reserved.
//

import UIKit

class ProfessorLoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var professorUsernameTextfield: UITextField!
    @IBOutlet weak var professorPasswordTextfield: UITextField!
    @IBOutlet weak var professorLoginButton: UIButton!
    
    @IBAction func professorLoginAction(_ sender: Any) {
        let username: String!  = professorUsernameTextfield.text
        let password: String!  = professorPasswordTextfield.text
        
        let credentialsFormatValid = UserLogin().validateInputCredential(username: username, password: password)
        let loginResult = UserLogin().login(username: username, password: password)
        
        if(credentialsFormatValid && loginResult) {
            //Successful login, segway.
            performSegue(withIdentifier: "professorLoginToProfessorViewSegway", sender: self)
        }
        else {
            //Unsuccessful login, display error.
            clearInputFields()
            
            let invalidLoginAlert = UIAlertController(title: "Failed to Login", message: "The username or password entered was incorrect!", preferredStyle: .alert)
            
            invalidLoginAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(invalidLoginAlert, animated: true)
        }
    }
    
    func clearInputFields(){
        professorUsernameTextfield.text = ""
        professorPasswordTextfield.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.professorUsernameTextfield.delegate = self
        self.professorPasswordTextfield.delegate = self
        
        //Visual changes
        professorLoginButton.layer.cornerRadius = 10
        professorLoginButton.clipsToBounds = true
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
