//
//  StudentViewController.swift
//  iBeaconAttendance
//
//  Created by Zachary Kimpfler on 11/14/19.
//  Copyright © 2019 kimpflerze. All rights reserved.
//

import UIKit

class StudentViewController: UIViewController {

    @IBOutlet weak var beaconingProfessorsTablbe: UITableView!
    
    var listener: TransmitterListener? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        listener = TransmitterListener()
        listener?.toggleListening()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        listener?.toggleListening()
        listener = nil
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
