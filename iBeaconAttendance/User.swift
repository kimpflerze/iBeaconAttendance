//
//  User.swift
//  iBeaconAttendance
//
//  Created by Zachary Kimpfler on 12/10/19.
//  Copyright © 2019 kimpflerze. All rights reserved.
//

import Foundation

class User {
    
    static var shared = User(userInformation: ["name": ""])
    
    var email: String? = nil
    var name: String = ""
    var firstName: String {
        let components = (name as NSString).components(separatedBy: " ")
        return components.first ?? ""
    }
    var lastName: String {
        let components = (name as NSString).components(separatedBy: " ")
        return components.last ?? ""
    }
    
    init(userInformation: [String : Any]) {
        email = userInformation["email"] as? String
        name = userInformation["name"] as? String ?? ""
    }
    
    
}
