//
//  Professor.swift
//  iBeaconAttendance
//
//  Created by Zachary Kimpfler on 12/7/19.
//  Copyright © 2019 kimpflerze. All rights reserved.
//

import Foundation

class Professor {
    var name: String? = nil
    var identifier: String? = nil
    var uuid: String? = nil
    var major: Int? = nil
    var minor: Int? = nil
    var proximity: Int? = nil
    var timestamp: Date? = nil
    
    //lostConnectionTimer used to determine if connection is lost.
    var lostConnectionTimer: Int = 30
    
    init(information: [String : Any]) {
        name = information["name"] as? String
        identifier = information["identifier"] as? String
        uuid = information["uuid"] as? String
        if let tempString = information["major"] as? String, let tempInt = Int(tempString) {
          major = tempInt
        }
        if let tempString = information["minor"] as? String, let tempInt = Int(tempString) {
          minor = tempInt
        }
        //major = information["major"] as? Int
        //minor  = information["minor"] as? Int
        proximity = information["proximity"] as? Int
        timestamp = information["timestamp"] as? Date
    }
    
}
