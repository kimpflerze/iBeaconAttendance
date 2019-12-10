//
//  User.swift
//  iBeaconAttendance
//
//  Created by Zachary Kimpfler on 12/10/19.
//  Copyright © 2019 kimpflerze. All rights reserved.
//

import Foundation

class User {
    
    var email: String? = nil
    var id: String? = nil
    
    init(userInformation: [String : Any]) {
        email = userInformation["email"] as? String
        id = userInformation["id"] as? String
    }
    
}
