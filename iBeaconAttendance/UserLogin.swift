//
//  UserLogin.swift
//  iBeaconAttendance
//
//  Created by Zachary Kimpfler on 11/17/19.
//  Copyright © 2019 kimpflerze. All rights reserved.
//

import Foundation

class UserLogin {
    
    func validateInputCredential(username: String!, password: String!) -> Bool {
        
        // Do any validation needed here.
        let modifiedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let modifiedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if(modifiedUsername.isEmpty || modifiedPassword.isEmpty) {
            return false
        }
        else {
            return true
        }
        
    }
    
    // Function for making login request to the back-end.
    func login(username: String!, password: String!) -> Bool {
        
        User.shared.email = username
        
        // Some logic to make request to back end.
        //
        // Return true if credentials match a user's.
        // Return false if credentials don't match any user's.
        
        return true
    }
    
}
