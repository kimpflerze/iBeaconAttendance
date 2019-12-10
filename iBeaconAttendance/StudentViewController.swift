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
    @IBOutlet weak var logoutButton: UIButton!
    
    var listener: TransmitterListener? = nil
    
    let notificationCenter = NotificationCenter.default
    
    //var discoveredBeaconIdentifiers: [String] = []
    var discoveredProfessorBeacons: [Professor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        listener = TransmitterListener()
        listener?.toggleListening()
        
        beaconingProfessorsTable.delegate = self
        beaconingProfessorsTable.dataSource = self
        
        //Notification center for detecting new professor beacon.
        notificationCenter.addObserver(self, selector: #selector(StudentViewController.onDidReceiveData), name: .discoveredNewBeacon, object: nil)
        
        //Visual changes
        logoutButton.layer.cornerRadius = 10
        logoutButton.clipsToBounds = true
        
        beaconingProfessorsTable.layer.masksToBounds = true
        beaconingProfessorsTable.layer.borderColor = Utilities.iBeaconAttendanceBlue.cgColor
        beaconingProfessorsTable.layer.borderWidth = 2.0
        beaconingProfessorsTable.layer.cornerRadius = 10
    }
    
    func identifierIsDiscovered(identifier: String) -> Bool {
        for professor in discoveredProfessorBeacons {
            if(professor.identifier == identifier) {
                return true
            }
        }
        
        return false
    }
    
    @objc func onDidReceiveData(_ notification:Notification) {
        // Do something now
        let userInfo = notification.userInfo
        let identifier = userInfo?["identifier"] as! String
        let newProfessor = userInfo?["professor"] as! Professor
        
        // Fetch the Professor's name associated with the received identifier.
        
        // Append the Professor's name into the table, instead of the identifier.
        /*
        if(!discoveredBeaconIdentifiers.contains(identifier)) {
            discoveredBeaconIdentifiers.append(identifier)
            
            beaconingProfessorsTable.beginUpdates()
            beaconingProfessorsTable.insertRows(at: [
                (NSIndexPath(row: discoveredBeaconIdentifiers.count-1, section: 0) as IndexPath)], with: .automatic)
            beaconingProfessorsTable.endUpdates()
        }
        */
        if(!identifierIsDiscovered(identifier: identifier)) {
            discoveredProfessorBeacons.append(newProfessor)
            
            beaconingProfessorsTable.beginUpdates()
            beaconingProfessorsTable.insertRows(at: [
                (NSIndexPath(row: discoveredProfessorBeacons.count-1, section: 0) as IndexPath)], with: .automatic)
            beaconingProfessorsTable.endUpdates()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        listener?.toggleListening()
        listener = nil

        NotificationCenter.default.removeObserver(notificationCenter)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return discoveredBeaconIdentifiers.count
        return discoveredProfessorBeacons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "beaconingProfessorCell")!
            
        //let text = discoveredBeaconIdentifiers[indexPath.row]
        let text = discoveredProfessorBeacons[indexPath.row].identifier
            
        cell.textLabel?.text = text
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        let alertController = UIAlertController(title: "Hint", message: "You have selected row \(indexPath.row).", preferredStyle: .alert)
            
        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            
        alertController.addAction(alertAction)
            
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func studentLogoutAction(_ sender: Any) {
        performSegue(withIdentifier: "studentLogoutSegway", sender: self)
    }
    
}
