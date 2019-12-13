//
//  UserLogin.swift
//  iBeaconAttendance
//
//  Created by Zachary Kimpfler on 11/17/19.
//  Copyright © 2019 kimpflerze. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserLogin {
    
    func validateInputCredential(email: String!, password: String!) -> Bool {
        
        // Do any validation needed here.
        let modifiedUsername = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let modifiedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if(modifiedUsername.isEmpty || modifiedPassword.isEmpty) {
            return false
        }
        else {
            return true
        }
        
    }
    
    func validateName(first: String!, last: String!) -> Bool {
        // Do any validation needed here.
        let modifiedFirst = first.trimmingCharacters(in: .whitespacesAndNewlines)
        let modifiedLast = last.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if(modifiedFirst.isEmpty || modifiedLast.isEmpty) {
            return false
        }
        else {
            return true
        }
    }
    
    func getFormattedCredentials(email: String!, password: String!) -> Dictionary<String,String>! {
        let modifiedUsername = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let modifiedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return ["username": modifiedUsername, "password": modifiedPassword]
    }
    
    func getFormattedName(first: String!, last: String!) -> Dictionary<String,String> {
        let modifiedFirst = first.trimmingCharacters(in: .whitespacesAndNewlines)
        let modifiedLast = last.trimmingCharacters(in: .whitespacesAndNewlines)
        let fullName = "\(modifiedFirst) \(modifiedLast)"
        
        return ["first": modifiedFirst, "last": modifiedLast, "full": fullName]
    }
    
    func createUser(email: String, password: String, fullName: String, type: Int, _ callback: ((Error?) -> ())? = nil){
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let e = error{
                callback?(e)
                return
            }
            self.addUserToFirestore(email: email, name: fullName, type: type)
            callback?(nil)
        }
    }
    
    func login(withEmail email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let e = error{
                print(e)
                // Present an error here using an alert.
                self.displayErrorAlert(title: "Sign In Error", msg: "There was an error while logging in, please try again.")
                
                return
            }
            
            guard let email = Auth.auth().currentUser?.email else {
                //Present an error here using an alert.
                //This shouldn't be reached, in theory. If login is successful, email is available.
                self.displayErrorAlert(title: "Sign In Error", msg: "There was an unexpected error while logging in, please try again or contact technical support.")
                
                return
            }
            
            //Get the user's name.
            UserLogin().getUserName(email: email)
        }
    }
    
    func sendPasswordReset(withEmail email: String){
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            self.displayErrorAlert(title: "Password Reset", msg: "An password reset request email has been sent to \(email)!")
        }
    }
    
    //Non-functional function.
    /*
    func createProfileNameChangeRequest(name: String? = nil, _ callback: ((Error?) -> ())? = nil){
        if let request = Auth.auth().currentUser?.createProfileChangeRequest(){
            if let name = name{
                request.displayName = name
            }

            request.commitChanges(completion: { (error) in
                callback?(error)
            })
        }
    }
    */
    
    func addUserToFirestore(email: String, name: String, type: Int) {
        let db = Firestore.firestore()
        
        let data:[String:Any] = ["name": name, "type": type]
        
        db.collection("Users").document(email).setData(data) { err in
            if let err = err {
                print("Error writing document: \(err)")
                
                self.displayErrorAlert(title: "Sign Up Error", msg: "There was an error when signing up, please try again.")
            } else {
                User.shared.email = email
                User.shared.name = name
                
                print("New User's Information: \(User.shared.name), \(User.shared.email ?? "")")
                
                //Segway to appropriate ViewController
                if(type == 0) {
                    //Segway to studentViewController
                    
                }
                else {
                    //Segway to professorViewController
                    
                }
                
            }
        }
    }
    
    func getUserName(email: String!) {
        let db = Firestore.firestore()
        
        let docRef = db.collection("Users").document(email)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let name = document.data()?["name"] as? String, let type = document.data()?["type"] as? Int else {
                    //Present a login error here, name wasnt found.
                    self.displayErrorAlert(title: "Sign In Error", msg: "There was an error when signing in, please try again or contact technical support.")
                    
                    return
                }
                
                User.shared.name = name
                User.shared.email = email
                
                print("Old User's Information: \(User.shared.name), \(User.shared.email ?? "")")
                
                //Segway to appropriate ViewController
                if(type == 0) {
                    //Segway to studentViewController
                    
                }
                else {
                    //Segway to professorViewController
                    
                }
                
            } else {
                print("User's name document does not exist!")
                
                //Present a login error here, name document wasnt found.
                //This shouldnt happen in theory, if it did, it would require admin intervention to resolve!
                self.displayErrorAlert(title: "Sign In Error", msg: "There was an error when signing in, please contact technical support!")
            }
        }
    }
    
    func checkIfExistingUserAndCreateUser(email: String, password: String, fullName: String, type: Int) {
        //Check if user exists.
        let db = Firestore.firestore()
        
        let docRef = db.collection("Users").document(email)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                //User exists, dont create user. Present alert and return!
                self.displayErrorAlert(title: "Sign Up Error", msg: "The email \(email) is already in use! Please reset your password if that is your email or use another address!")
                
                return
            } else {
                //User doesn't exist, create user.
                self.createUser(email: email, password: password, fullName: fullName, type: type)
            }
        }
        
    }
    
    func displayErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
}

extension UIApplication {

    static func topViewController(base: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }

        return base
    }
}
