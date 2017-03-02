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


class ViewController: UITableViewController {
    
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
        
        
        //loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
        
    }
    
    
    



}

