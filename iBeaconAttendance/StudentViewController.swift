//
//  StudentViewController.swift
//  iBeaconAttendance
//
//  Created by Zachary Kimpfler on 11/14/19.
//  Copyright © 2019 kimpflerze. All rights reserved.
//

import UIKit

class StudentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var beaconingProfessorsTable: UITableView!
    
    var listener: TransmitterListener? = nil
    var temporarydata: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        listener = TransmitterListener()
        listener?.toggleListening()
        
        beaconingProfessorsTable.delegate = self
        beaconingProfessorsTable.dataSource = self
        
        //Fill in some sample data
        for i in 0...100 {
            temporarydata.append(String(i))
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        listener?.toggleListening()
        listener = nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return temporarydata.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "beaconingProfessorCell")!
            
         let text = temporarydata[indexPath.row]
            
         cell.textLabel?.text = text
            
         return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
         let alertController = UIAlertController(title: "Hint", message: "You have selected row \(indexPath.row).", preferredStyle: .alert)
            
         let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            
         alertController.addAction(alertAction)
            
         present(alertController, animated: true, completion: nil)
            
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
