//
//  TransmitterListener.swift
//  iBeaconAttendance
//
//  Created by Zachary Kimpfler on 11/18/19.
//  Copyright © 2019 kimpflerze. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth
import FirebaseFirestore

typealias Callback = (Array<Dictionary<String,Any>>) -> Void

class TransmitterListener: NSObject, CBPeripheralManagerDelegate, CLLocationManagerDelegate {

    static var shared = TransmitterListener()
    
    var callback: Callback? = nil
    
    // shared
    let proximityUUID =  UUID(uuidString: "39ED98FF-2900-441A-802F-9C398FC199D2")
    let beaconID = "com.example.myDeviceRegion"
    final let newBeaconNotification = "newBeaconNotification"

    // Transmitting
    var peripheralManager: CBPeripheralManager? = nil
    var transmittingRegion: CLBeaconRegion? = nil
    var beaconPeripheralData: NSDictionary? = nil
    
    // Max Value: 65535
    let major : CLBeaconMajorValue = 100
    let minor : CLBeaconMinorValue = 1
    
    //private var detectedBeacons = [String : [String : String]]()
    private var detectedProfessorBeacons: [String : Any] = [String : Any]()
    
    lazy var transBeaconRegion: CLBeaconRegion? = {
        return CLBeaconRegion(proximityUUID: proximityUUID!,
                              major: major,
                              minor: minor,
                              identifier: beaconID)
    }()
    
    // listening
    var locationManager: CLLocationManager? = nil
    var listeningRegion: CLBeaconRegion? = nil

    lazy var listBeaconRegion: CLBeaconRegion? = {
        return CLBeaconRegion(proximityUUID: proximityUUID!,
                              identifier: beaconID)
    }()
    
    /*
    func getDetectedBeacons() -> [String : Professor] {
        return detectedProfessorBeacons
    }
    */
 
    // Start/stop transmitting
    func toggleTransmitting() {
        if let manager = peripheralManager {
            
            //Stop transmitting
            
            manager.stopAdvertising()
            peripheralManager = nil
            transmittingRegion = nil
        }
        else {
            
            //Start transmitting
            
            peripheralManager = CBPeripheralManager(delegate: self,
                                                    queue: nil)
            
            beaconPeripheralData = transBeaconRegion?.peripheralData(withMeasuredPower: nil)
        }
    }
    
    func forceStopTransmitting() {
        //Stop transmitting
        peripheralManager?.stopAdvertising()
        peripheralManager = nil
        transmittingRegion = nil
    }
    
    // Start/stop listening
    func toggleListening() {
        let rangedRegions = {
            self.locationManager?.rangedRegions as? Set<CLBeaconRegion>
        }
        
        if let regions = rangedRegions(), regions.count > 0 {
            
            //Stop listening
            
            regions.forEach { locationManager?.stopRangingBeacons(in: $0) }
            
            locationManager?.delegate = nil
            locationManager = nil
            listeningRegion = nil
        }
        else {
            
            //Start listening
            
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestAlwaysAuthorization()
        }
    }
        
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard status == .authorizedAlways
            && CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)
            && CLLocationManager.isRangingAvailable() else { return }
        
        startScanning()
    }
    
    func startScanning() {
        guard let beaconRegion = listBeaconRegion else { return }
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didRangeBeacons beacons: [CLBeacon],
                         in region: CLBeaconRegion) {
        
        detectedProfessorBeacons.removeAll()
        
        guard (beacons.count > 0) else {
            callback?([])
            return
        }
        
        beacons.forEach{ beacon in
            let identifier = "\(beacon.major):\(beacon.minor)"
            var information: [String : String] = [:]
            var professor: Professor = Professor(information: information)
            
            if #available(iOS 13.0, *) {
                //print("\($0.uuid) \($0.major) \($0.minor) \($0.proximity) \($0.timestamp)")
                let uuid = "\(beacon.uuid)"
                let major = "\(beacon.major)"
                let minor = "\(beacon.minor)"
                let proximity = "\(beacon.proximity)"
                let timestamp = "\(beacon.timestamp)"
                information = ["uuid": uuid, "major": major, "minor": minor, "proximity": proximity, "timestamp": timestamp, "identifier": identifier]
                professor = Professor(information: information)
                //detectedBeacons[identifier] = information
                
            } else {
                //print("\($0.proximityUUID) \($0.major) \($0.minor) \($0.proximity)")
                let uuid = "\(beacon.proximityUUID)"
                let major = "\(beacon.major)"
                let minor = "\(beacon.minor)"
                let proximity = "\(beacon.proximity)"
                information = ["uuid": uuid, "major": major, "minor": minor, "proximity": proximity, "identifier": identifier]
                professor = Professor(information: information)
                //detectedBeacons[identifier] = information
                
            }
            
            //Make asynchronous call to back-end now to fetch name.
            //Post to notification center after return.
            let db = Firestore.firestore()
            
            let docRef = db.collection("Beacons").document(identifier)

            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    
                    guard var params = document.data() else {
                        return
                    }
                    
                    (document.data()?["professorRef"] as? DocumentReference)?.getDocument { (document, error) in
                        if let document = document, document.exists {
                            
                            professor.name = document.data()?["name"] as? String ?? ""
                            
                        } else {
                            print("Inner document does not exist")
                        }
                        
                        params["professorRef"] = (params["professorRef"] as? DocumentReference)?.documentID
                        params["professor"] = professor
                        params["beaconRef"] = identifier
                        
                        self.detectedProfessorBeacons[identifier] = params
                        
                        if let parameterArray = self.detectedProfessorBeacons.values.map({ $0 }) as? Array<Dictionary<String,Any>> {
                            self.callback?(parameterArray)
                        }
                        
                        //NotificationCenter.default.post(name: .discoveredNewBeacon, object: nil, userInfo: ["identifier": identifier, "professor" : professor])
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
        
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        guard peripheral.state == .poweredOn else { return }
        print("Transmitting on!")
        peripheral.startAdvertising(beaconPeripheralData as? [String: Any])
    }
    
}

extension Notification.Name {
    static let discoveredNewBeacon = Notification.Name(
       rawValue: "discoveredNewBeacon")
}
