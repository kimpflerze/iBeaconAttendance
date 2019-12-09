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
        
        for i in 1...100 {
            presentStudents.append(String(i))
        }
        
        //Visual changes
        logoutButton.layer.cornerRadius = 10
        logoutButton.clipsToBounds = true
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
           
        cell.textLabel?.text = text
           
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Hint", message: "You have selected row \(indexPath.row).", preferredStyle: .alert)
           
        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
           
        alertController.addAction(alertAction)
           
        present(alertController, animated: true, completion: nil)
    }

}
