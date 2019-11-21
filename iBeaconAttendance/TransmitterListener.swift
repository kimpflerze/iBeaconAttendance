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
    
    var transmitting: Bool = false
    var listening: Bool = false
    
    var locationManager: CLLocationManager? = nil
    
    var peripheralManager: CBPeripheralManager? = nil
    var transmittingRegion: CLBeaconRegion? = nil
    var listeningRegion: CLBeaconRegion? = nil
    
    // Start/stop transmitting
    func toggleTransmitting() {
        if(transmitting) {
            //Stop transmitting
            peripheralManager?.stopAdvertising()
            
            peripheralManager = nil
            transmittingRegion = nil
        }
        else {
            //Start transmitting
            print("Transmitting toggling")
            if let tempRegion = createTransmittingBeaconRegion() {
                let tempPeripheral = CBPeripheralManager(delegate: self, queue: nil)
                let peripheralData = tempRegion.peripheralData(withMeasuredPower: nil)
                
                //This cant be called until after the Bluetooth component is on.
                //I added a statement in the function below.
                //tempPeripheral.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
                
                peripheralManager = tempPeripheral
                transmittingRegion = tempRegion
            }
        }
        transmitting = !transmitting
    }
    
    func forceStopTransmitting() {
        //Stop transmitting
        peripheralManager?.stopAdvertising()
        
        peripheralManager = nil
        transmittingRegion = nil
    }
    
    // Start/stop listening
    func toggleListening() {
        if(listening) {
            //Stop listening
            guard let tempRegion = listeningRegion else {
                return
            }
            
            locationManager?.delegate = nil
            
            locationManager?.stopRangingBeacons(in: tempRegion)
            
            locationManager = nil
            listeningRegion = nil
        }
        else {
            //Start listening
            if let tempRegion = createListeningBeaconRegion() {
                let tempLocationManager = CLLocationManager()
                
                tempLocationManager.delegate = self
                
                tempLocationManager.startRangingBeacons(in: tempRegion)
                
                locationManager = tempLocationManager
                listeningRegion = tempRegion
            }
        }
        listening = !listening
    }
    
    func createTransmittingBeaconRegion() -> CLBeaconRegion? {
        let proximityUUID = UUID(uuidString:
            "39ED98FF-2900-441A-802F-9C398FC199D2")
        let major : CLBeaconMajorValue = 100
        let minor : CLBeaconMinorValue = 1
        let beaconID = "com.example.myDeviceRegion"
        
        return CLBeaconRegion(proximityUUID: proximityUUID!,
                              major: major, minor: minor, identifier: beaconID)
    }
    
    func createListeningBeaconRegion() -> CLBeaconRegion? {
        let proximityUUID = UUID(uuidString:
            "39ED98FF-2900-441A-802F-9C398FC199D2")
        let beaconID = "com.example.myDeviceRegion"
        
        return CLBeaconRegion(proximityUUID: proximityUUID!, identifier: beaconID)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print(beacons)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            print("Bluetooth on!")
            if(transmitting) {
                //I know that my region has a value when turned on.
                //I also know that my transmitting Bool is true.
                print("Transmitting on!")
                let beaconPeripheralData = transmittingRegion?.peripheralData(withMeasuredPower: nil)
                print(beaconPeripheralData ?? "nil")
                peripheralManager?.startAdvertising(beaconPeripheralData as? [String: Any])
            }
            if(listening) {
                print("Listening on!")
            }
        } else if peripheral.state == .poweredOff {
            peripheralManager?.stopAdvertising()
        }
    }
    
}
