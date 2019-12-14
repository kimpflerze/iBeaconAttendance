//
//  ProfessorViewController.swift
//  iBeaconAttendance
//
//  Created by Zachary Kimpfler on 11/14/19.
//  Copyright © 2019 kimpflerze. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ProfessorViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    var transmitter: TransmitterListener? = nil
    var presentStudents: [String:Student] = [:]
    var sortedPresentStudents: [Student] {
        if let sortedStudents = _sortedPresentStudents {
            return sortedStudents
        }
        
        let sortedStudents = presentStudents.values.sorted(by: { (studentOne, studentTwo) -> Bool in
            return studentOne.lastName < studentTwo.lastName
        })
        
        _sortedPresentStudents = sortedStudents
        
        return sortedStudents
    }
    var _sortedPresentStudents: [Student]? = nil
    
    var transmissionInformation: [String : Any] = [:]
    
    @IBOutlet weak var logsButton: UIButton!
    @IBOutlet weak var courseNameTextfield: UITextField!
    @IBOutlet weak var transmissionSwitch: UISwitch!
    @IBOutlet weak var presentStudentsTable: UITableView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func reloadTable(_ sender: Any) {
        presentStudentsTable.reloadData()
    }
    
    @IBAction func transmissionAction(_ sender: Any) {
        //transmitter?.toggleTransmitting()
        
        //Check if courseNameTextfield is empty before beginning transmission.
        guard let className = courseNameTextfield.text, !className.isEmpty else {
            let courseNameTextfieldEmptyAlert = UIAlertController(title: "No Course Name", message: "The course name input field is empty, please input a course name!", preferredStyle: .alert)
            
            courseNameTextfieldEmptyAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            transmissionSwitch.setOn(false, animated: true)
            
            self.present(courseNameTextfieldEmptyAlert, animated: true)
            
            return
        }
        
        //If transmissionSwitch is turning on
        if(transmissionSwitch.isOn) {
            //Present spinner wheel to show in-progress actions.
            activityIndicator.startAnimating()
            
            //Get next available minor/major information from database.
                //I have some options here.
            
                //TEMPORARY RESOLUTION, IMPLEMENT CLOUD FUNCTION HERE
            //let randomMinor = Int.random(in: 0..<65535)
            //let randomMajor = Int.random(in: 0..<65535)
            
            
            //Check if the professor has a beacon for the class.
            transmitter?.getBeaconInformationAndToggleTransmitting(className: className, professorEmail: User.shared.email ?? "")
            
            
            
                //Create listener for new updates in Log collection on Firebase back-end.
        }
        else {
            transmitter?.toggleTransmitting()
            transmitter?.forceStopTransmitting()
        }
        
        //Turn off spinner wheel to show in-progress actions as complete.
        
        
    }
    
    @objc func beaconInformationReady(information: Dictionary<String,String>) {
        let db = Firestore.firestore()
        
        let documentRefString = db.collection("Users").document(User.shared.email ?? "")
        let professorRef = db.document(documentRefString.path)
        
        let beaconIdentifier = "\(information["major"] ?? ""):\(information["minor"] ?? "")"
        
        //Save transmissionInformation - timestamp, beaconRef, professorRef as ID
        transmissionInformation["professorRef"] = professorRef
        transmissionInformation["major"] = information["major"]
        transmissionInformation["minor"] = information["minor"]
        transmissionInformation["beaconRef"] = beaconIdentifier
        transmissionInformation["timestamp"] = Date().timeIntervalSince1970
        transmissionInformation["className"] = information["className"]
        
        print("beaconInformationReadyCallback data: \(information["major"] ?? ""):\(information["minor"] ?? "") for class \(information["className"] ?? "")")
        
        if(information["newEntry"] == "1") {
            //Add beacon to the Beacon collection for students to reference.
            db.collection("Beacons").document(beaconIdentifier).setData([
                "timestamp": transmissionInformation["timestamp"] ?? Date().timeIntervalSince1970,
                "professorRef": transmissionInformation["professorRef"] ?? "",
                "className": transmissionInformation["className"] ?? ""
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("New beacon for \(User.shared.email ?? "") in class \(information["className"] ?? "") successfully created!")
                    
                    self.transmitter?.toggleTransmitting()
                    
                    //Alert the user of transmission status toggle.
                    let transmitterToggleAlert = UIAlertController(title: "Transmitter Status", message: "The transmitter status was toggled!", preferredStyle: .alert)
                    
                    transmitterToggleAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    
                    self.present(transmitterToggleAlert, animated: true)
                }
            }
        }
        else {
            //Else statement because if it is a new entry, we only want to begin transmitting once entry is added to Firestore
            transmitter?.toggleTransmitting()
            
            //Alert the user of transmission status toggle.
            let transmitterToggleAlert = UIAlertController(title: "Transmitter Status", message: "The transmitter status was toggled!", preferredStyle: .alert)
            
            transmitterToggleAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(transmitterToggleAlert, animated: true)
        }
        
        activityIndicator.stopAnimating()
        
    }
    
    @IBAction func logsAction(_ sender: Any) {
        performSegue(withIdentifier: "professorLogsSegway", sender: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        transmitter = TransmitterListener()
        transmitter?.beaconReadyCallback = beaconInformationReady
        
        self.courseNameTextfield.delegate = self
        
        presentStudentsTable.delegate = self
        presentStudentsTable.dataSource = self
        
        //Visual changes
        logsButton.layer.cornerRadius = 10
        logsButton.clipsToBounds = true
        
        logoutButton.layer.cornerRadius = 10
        logoutButton.clipsToBounds = true
        
        presentStudentsTable.layer.masksToBounds = true
        presentStudentsTable.layer.borderColor = Utilities.iBeaconAttendanceBlue.cgColor
        presentStudentsTable.layer.borderWidth = 2.0
        presentStudentsTable.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let db = Firestore.firestore()
        
        let documentRefString = db.collection("Users").document(User.shared.email ?? "")
        let professorRef = db.document(documentRefString.path)
        
        db.collection("Logs")
            .whereField("professorRef", isEqualTo: professorRef)
            .whereField("timestamp", isGreaterThan: transmissionInformation["timestamp"] ?? 0)
            .whereField("beaconRef", isEqualTo: transmissionInformation["beaconRef"] ?? "")
            .addSnapshotListener { querySnapshot, error in
                
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                for document in documents {
                    print(document.data())
                    
                    if let studentRef = (document.data()["studentRef"] as? DocumentReference)?.documentID {
                        if(self.presentStudents[studentRef] != nil) {
                            continue
                        }
                    }
                    
                    (document.data()["studentRef"] as? DocumentReference)?.getDocument { (document, error) in
                        if let document = document, document.exists, let data = document.data() {
                            let student = Student(userInformation: data)
                            
                            let count = self.sortedPresentStudents.count
                            
                            guard self.presentStudents[student.name] == nil else {
                                return
                            }
                            
                            self.presentStudents[student.name] = student
                            self._sortedPresentStudents = nil
                            
                            let sortedStudents = self.sortedPresentStudents
                            if let index = sortedStudents.firstIndex(where: { $0.name == student.name }), index < count {
                                self.presentStudentsTable.insertRows(at: [IndexPath(row: index, section: 0)], with: .right)
                            }
                            else {
                                self.presentStudentsTable.reloadData()
                            }
                        } else {
                            print("Inner document does not exist")
                        }
                    }
                }
                
        }
        
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
           
        let text = sortedPresentStudents[indexPath.row].name
           
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
        if(UserLogin().signOut()) {
            performSegue(withIdentifier: "professorLogoutSegway", sender: self)
        }
        else {
            UserLogin().displayErrorAlert(title: "Sign Out Error", msg: "There was an error while signing out, please try again.")
        }
    }
    
}
