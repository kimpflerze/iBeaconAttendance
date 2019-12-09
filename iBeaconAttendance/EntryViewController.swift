//
//  ViewController.swift
//  iBeaconAttendance
//
//  Created by Zachary Kimpfler on 11/13/19.
//  Copyright © 2019 kimpflerze. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var studentLoginButton: UIButton!
    @IBOutlet weak var professorLogin: UIButton!
    
    @IBAction func toStudentLoginAction(_ sender: Any) {
        performSegue(withIdentifier: "entryToStudentLoginSegway", sender: self)
    }
    
    @IBAction func toProfessorLoginAction(_ sender: Any) {
        performSegue(withIdentifier: "entryToProfessorLoginSegway", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Visual changes
        studentLoginButton.layer.cornerRadius = 10
        studentLoginButton.clipsToBounds = true
        
        professorLogin.layer.cornerRadius = 10
        professorLogin.clipsToBounds = true
        
    }


}

