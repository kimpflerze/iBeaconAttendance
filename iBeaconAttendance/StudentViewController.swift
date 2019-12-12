//
//  StudentViewController.swift
//  iBeaconAttendance
//
//  Created by Zachary Kimpfler on 11/14/19.
//  Copyright © 2019 kimpflerze. All rights reserved.
//

import UIKit
import FirebaseFirestore

class StudentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var beaconingProfessorsTable: UITableView!
    @IBOutlet weak var logoutButton: UIButton!
    
    var listener: TransmitterListener? = nil
    
    //var discoveredBeaconIdentifiers: [String] = []
    var discoveredProfessorBeacons: [[String : Any]] = []
    var sortedBeacons: [[String:Any]] {
        return discoveredProfessorBeacons.sorted { (beaconOne, beaconTwo) -> Bool in
            let professorOne = (beaconOne["professor"] as? Professor)?.lastName ?? ""
            let professorTwo = (beaconTwo["professor"] as? Professor)?.lastName ?? ""
            return professorOne < professorTwo
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        listener = TransmitterListener.shared
        listener?.newBeaconDataCallback = onDidReceiveData
        listener?.toggleListening()
        
        beaconingProfessorsTable.delegate = self
        beaconingProfessorsTable.dataSource = self
        
        //Notification center for detecting new professor beacon.
        //notificationCenter.addObserver(self, selector: #selector(StudentViewController.onDidReceiveData), name: .discoveredNewBeacon, object: nil)
        
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
            if((professor["professor"] as? Professor)?.email == identifier) {
                return true
            }
        }
        
        return false
    }
    
    @objc func onDidReceiveData(_ notification:Array<Dictionary<String,Any>>) {
        discoveredProfessorBeacons = notification
        beaconingProfessorsTable.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        listener?.toggleListening()
        listener = nil

        //NotificationCenter.default.removeObserver(notificationCenter)
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
        let text = (sortedBeacons[indexPath.row]["professor"] as? Professor)?.name
            
        cell.textLabel?.text = text
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Make async call to mark present
        
        //Timestamp, StudentID, ProfessorID, className, BeaconID,
        let db = Firestore.firestore()
        
        var ref: DocumentReference? = nil
        
        let information = discoveredProfessorBeacons[indexPath.row]
        
        let documentRefString = db.collection("Users").document(User.shared.email ?? "")
        let studentRef = db.document(documentRefString.path)
        
        ref = db.collection("Logs").addDocument(data: [
            "timestamp": Date().timeIntervalSince1970,
            "studentRef": studentRef,
            "professorRef": information["professorRef"] ?? "",
            "className": information["className"] ?? "",
            "beaconRef": information["beaconRef"] ?? ""
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                
                let alertController = UIAlertController(title: "Notice", message: "You have been marked present in \((information["professor"] as? Professor)?.name ?? "nil")'s course, \(information["className"] ?? "nil").", preferredStyle: .alert)
                    
                let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    
                alertController.addAction(alertAction)
                    
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func studentLogoutAction(_ sender: Any) {
        performSegue(withIdentifier: "studentLogoutSegway", sender: self)
    }
    
}
