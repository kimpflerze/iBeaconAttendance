//
//  ProfessorViewController.swift
//  iBeaconAttendance
//
//  Created by Zachary Kimpfler on 11/14/19.
//  Copyright © 2019 kimpflerze. All rights reserved.
//

import UIKit

class ProfessorViewController: UIViewController, UITextFieldDelegate {

    var transmitter: TransmitterListener? = nil
    
    @IBOutlet weak var courseNameTextfield: UITextField!
    @IBOutlet weak var transmissionSwitch: UISwitch!
    
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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        transmitter?.forceStopTransmitting()
        transmitter = nil
        
        transmissionSwitch.setOn(false, animated: false)
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
