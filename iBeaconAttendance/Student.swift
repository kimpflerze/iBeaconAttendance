//
//  Student.swift
//  iBeaconAttendance
//
//  Created by Zachary Kimpfler on 12/7/19.
//  Copyright © 2019 kimpflerze. All rights reserved.
//

import Foundation

class Student {
    var name: String? = nil
    var identifier: String? = nil
    
    init(studentInformation: [String : Any]) {
        name = studentInformation["name"] as? String
        identifier = studentInformation["identifier"] as? String
    }
}
