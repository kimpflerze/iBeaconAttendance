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
    
    init(professorInformation: [String : Any]) {
        name = professorInformation["name"] as? String
        identifier = professorInformation["identifier"] as? String
        uuid = professorInformation["uuid"] as? String
        major = professorInformation["major"] as? Int
        minor  = professorInformation["minor"] as? Int
        proximity = professorInformation["proximity"] as? Int
        timestamp = professorInformation["timestamp"] as? Date
    }
    
}
