//
//  ProfessorLogsViewController.swift
//  iBeaconAttendance
//
//  Created by Zachary Kimpfler on 12/13/19.
//  Copyright © 2019 kimpflerze. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ProfessorLogsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var classNameTextfield: UITextField!
    @IBOutlet weak var classDatePicker: UIDatePicker!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var logsTableView: UITableView!
    
    var retrievedLogs: Array<Dictionary<String,Any>>? = nil
    
    @IBAction func searchAction(_ sender: Any) {
        //Make query to get relevant logs here!
        
        retrievedLogs = []
        logsTableView.reloadData()
        
        //Check if courseNameTextfield is empty before beginning transmission.
        guard let className = classNameTextfield.text, !className.isEmpty else {
            let courseNameTextfieldEmptyAlert = UIAlertController(title: "No Course Name", message: "The course name input field is empty, please input a course name!", preferredStyle: .alert)
            
            courseNameTextfieldEmptyAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(courseNameTextfieldEmptyAlert, animated: true)
            
            return
        }
        
        let datePickerValue = classDatePicker.date
        let startOfDay = datePickerValue.startOfDay.timeIntervalSince1970
        let endOfDay = datePickerValue.endOfDay.timeIntervalSince1970
        
        //Make query here
        let db = Firestore.firestore()
        
        //Build professorRef here
        let documentRefString = db.collection("Users").document(User.shared.email ?? "")
        let professorRef = db.document(documentRefString.path)
        
        db.collection("Logs")
            .whereField("professorRef", isEqualTo: professorRef)
            .whereField("className", isEqualTo: className)
            .whereField("timestamp", isGreaterThanOrEqualTo: startOfDay)
            .whereField("timestamp", isLessThanOrEqualTo: endOfDay)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    for document in querySnapshot!.documents {
                        
                        var currentLog: [String : Any] = [:]
                        
                        if let timeInterval = document.data()["timestamp"] as? TimeInterval {
                            let date = Date(timeIntervalSince1970: timeInterval)
                            
                            let currentLocaleTime = date.toLocalTime().description
                            
                            currentLog["timestamp"] = "\(currentLocaleTime)"
                        }
                        
                        (document.data()["studentRef"] as? DocumentReference)?.getDocument { (document, error) in
                            if let document = document, document.exists, let data = document.data() {
                                currentLog["name"] = data["name"]
                                
                                self.retrievedLogs?.append(currentLog)
                                
                                //if let index = self.retrievedLogs?.count {
                                if let index = self.retrievedLogs?.count {
                                    self.logsTableView.insertRows(at: [IndexPath(row: index - 1, section: 0)], with: .automatic)
                                }
                            } else {
                                print("Inner document does not exist")
                            }
                        }
                        
                        
                    }
                }
        }
        
        logsTableView.reloadData()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return discoveredBeaconIdentifiers.count
        guard let count = retrievedLogs?.count else {
            return 0
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logCell")!
            
        var timestamp = (retrievedLogs?[indexPath.row]["timestamp"] as? String) ?? ""
        
        let startIndex = timestamp.index(timestamp.startIndex, offsetBy: 6)
        timestamp = String(timestamp[startIndex...])
        if let endIndex = timestamp.range(of: " +0000")?.lowerBound {
            timestamp = String(timestamp[..<endIndex])
        }
        
        let name = retrievedLogs?[indexPath.row]["name"] ?? ""
        
        let text = "\(timestamp) - \(name)"
            
        cell.textLabel?.text = text
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Do something if row is tapped.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        logsTableView.delegate = self
        logsTableView.dataSource = self
        
        classNameTextfield.delegate = self
        
        //Visual changes
        searchButton.layer.cornerRadius = 10
        searchButton.clipsToBounds = true
        
        classDatePicker.layer.masksToBounds = true
        classDatePicker.layer.borderColor = Utilities.textfieldBorderGrey.cgColor
        classDatePicker.layer.borderWidth = 1.0
        classDatePicker.layer.cornerRadius = 10
        classDatePicker.backgroundColor = .white
        
        logsTableView.layer.masksToBounds = true
        logsTableView.layer.borderColor = Utilities.iBeaconAttendanceBlue.cgColor
        logsTableView.layer.borderWidth = 2.0
        logsTableView.layer.cornerRadius = 10
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

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}
