//
//  ViewController.swift
//  tester33
//
//  Created by Horea on 2/9/17.
//  Copyright © 2017 Horea Porutiu. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class ViewController: UITableViewController,FBSDKLoginButtonDelegate {
    
    var ref:FIRDatabaseReference?
    
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
            
        }   catch let logoutError {
            print(logoutError)
        }
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }

   


    override func viewDidLoad() {
        super.viewDidLoad()
        
               
      
        


        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            
       
            handleLogout()
        }

    
        
        
        let loginButton = FBSDKLoginButton()
        
        view.addSubview(loginButton)
        loginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32, height: 50)
        
        
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("did log out of fb")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
         print (error)
            return
        }
        print ("successfuly logged in with facebook")
        
     
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user,error) in
            if error != nil {
                print ("something went wrong with our FB user: ", error ?? "")
                return
            }
            print("successfully logged in with our user: ", user ?? "")

            
        })
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, err) in
            
            
            
            print(123)
            
            if err != nil {
                print("failed to start graph request:" , err ?? "")
                return
            }//
            
            
            
            print(type(of:result))
            print(result ?? "")
            
            self.ref = FIRDatabase.database().reference()
            
            self.ref?.child("users").childByAutoId().setValue(result)
        }
    }
    
    



}

