//
//  ProfessorViewController.swift
//  iBeaconAttendance
//
//  Created by Zachary Kimpfler on 11/14/19.
//  Copyright © 2019 kimpflerze. All rights reserved.
//

import UIKit

class ProfessorViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    var transmitter: TransmitterListener? = nil
    var presentStudents: [String] = []
    
    @IBOutlet weak var courseNameTextfield: UITextField!
    @IBOutlet weak var transmissionSwitch: UISwitch!
    @IBOutlet weak var presentStudentsTable: UITableView!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func transmissionAction(_ sender: Any) {
        transmitter?.toggleTransmitting()
        
        //Check if courseNameTextfield is empty before beginning transmission.
        guard let text = courseNameTextfield.text, !text.isEmpty else {
            let courseNameTextfieldEmptyAlert = UIAlertController(title: "No Course Name", message: "The course name input field is empty, please input a course name!", preferredStyle: .alert)
            
            courseNameTextfieldEmptyAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            transmissionSwitch.setOn(false, animated: true)
            
            self.present(courseNameTextfieldEmptyAlert, animated: true)
            
            return
        }
        
        let transmitterToggleAlert = UIAlertController(title: "Transmitter Status", message: "The transmitter status was toggled!", preferredStyle: .alert)
        
        transmitterToggleAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(transmitterToggleAlert, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        transmitter = TransmitterListener()
        
        self.courseNameTextfield.delegate = self
        
        presentStudentsTable.delegate = self
        presentStudentsTable.dataSource = self
        
        for i in 1...20 {
            presentStudents.append(String(i))
        }
        
        //Visual changes
        logoutButton.layer.cornerRadius = 10
        logoutButton.clipsToBounds = true
        
        presentStudentsTable.layer.masksToBounds = true
        presentStudentsTable.layer.borderColor = Utilities.iBeaconAttendanceBlue.cgColor
        presentStudentsTable.layer.borderWidth = 2.0
        presentStudentsTable.layer.cornerRadius = 10
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        transmitter?.forceStopTransmitting()
        transmitter = nil
        
        transmissionSwitch.setOn(false, animated: false)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentStudents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "presentStudentCell")!
           
        let text = presentStudents[indexPath.row]
           
        cell.textLabel?.text = String(indexPath.row + 1) + ". " + text
           
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Hint", message: "You have selected row \(indexPath.row).", preferredStyle: .alert)
           
        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
           
        alertController.addAction(alertAction)
           
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func professorLogoutAction(_ sender: Any) {
        performSegue(withIdentifier: "professorLogoutSegway", sender: self)
    }
    
}
