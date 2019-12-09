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

class TransmitterListener: NSObject, CBPeripheralManagerDelegate, CLLocationManagerDelegate {

    // shared
    let proximityUUID =  UUID(uuidString: "39ED98FF-2900-441A-802F-9C398FC199D2")
    let beaconID = "com.example.myDeviceRegion"
    final let newBeaconNotification = "newBeaconNotification"

    // transmitting
    var peripheralManager: CBPeripheralManager? = nil
    var transmittingRegion: CLBeaconRegion? = nil
    var beaconPeripheralData: NSDictionary? = nil
    
    let major : CLBeaconMajorValue = 100
    let minor : CLBeaconMinorValue = 1
    
    private var detectedBeacons = [String : [String : String]]()
    
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
    
    func getDetectedBeacons() -> Dictionary<String, [String : String]> {
        return detectedBeacons
    }

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
        
        beacons.forEach {
            let identifier = "\($0.major).\($0.minor)"
            var information: [String : String] = [:]
            
            if #available(iOS 13.0, *) {
                //print("\($0.uuid) \($0.major) \($0.minor) \($0.proximity) \($0.timestamp)")
                let uuid = "\($0.uuid)"
                let major = "\($0.major)"
                let minor = "\($0.minor)"
                let proximity = "\($0.proximity)"
                let timestamp = "\($0.timestamp)"
                information = ["uuid": uuid, "major": major, "minor": minor, "proximity": proximity, "timestamp": timestamp]
                detectedBeacons[identifier] = information
            } else {
                //print("\($0.proximityUUID) \($0.major) \($0.minor) \($0.proximity)")
                let uuid = "\($0.proximityUUID)"
                let major = "\($0.major)"
                let minor = "\($0.minor)"
                let proximity = "\($0.proximity)"
                information = ["uuid": uuid, "major": major, "minor": minor, "proximity": proximity]
                detectedBeacons[identifier] = information
            }
            
            NotificationCenter.default.post(name: .discoveredNewBeacon, object: nil, userInfo: ["identifier" : identifier])
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
