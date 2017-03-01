//
//  LoginController.swift
//  tester33
//
//  Created by Horea on 2/15/17.
//  Copyright © 2017 Horea Porutiu. All rights reserved.
//
import UIKit
import Firebase
import FBSDKLoginKit
//import FacebookLogin
class LoginController: UIViewController, FBSDKLoginButtonDelegate {
    /**
     Sent to the delegate when the button was used to logout.
     - Parameter loginButton: The button that was clicked.
     */
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print(1234)
    }
    
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 255, g:255, b:255)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let loginRegisterButton: UIButton = {
        let button = UIButton (type: .system)
        button.backgroundColor = UIColor(r: 160, g:15, b:16)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, err) in
            
            if err != nil {
                print("Failed to start graph request:", err)
                return
            }
            print(result)
        }
    }
    
    func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                print(error ?? "")
                return
            }
            
            //successfully logged in our user
            self.dismiss(animated: true, completion: nil)
            
        })
        
    }
    
    func handleRegister() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text
            else {
                print("Form is not valid")
                return
        }
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            if error != nil {
                print(error ?? "")
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            // successfully auth user
            let ref = FIRDatabase.database().reference(fromURL: "https://tester3-8fca0.firebaseio.com/")
            let usersReference = ref.child("users").child(uid)
            let values = ["name": name, "email": email]
            usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err ?? "")
                    return
                }
                
                print("saved user successfully into FB DB")
                self.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    let customFBButton: UIButton = {
        let customFBBut = UIButton(type: .system)
        customFBBut.backgroundColor = UIColor(r: 160, g:15, b:16)
        //customFBButton.frame = CGRect(x: 16, y: 520, width: loginRegisterButton.width, height: 50)
        customFBBut.setTitle("Login with Facebook", for: .normal)
        customFBBut.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customFBBut.setTitleColor(.white, for: .normal)
        customFBBut.translatesAutoresizingMaskIntoConstraints = false
        customFBBut.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        return customFBBut
    }()//
    
    /*let profileImageView: UIImageView = {
     let imageView = UIImageView()
     imageView.image = UIImage(named: "servrLogo")
     imageView.translatesAutoresizingMaskIntoConstraints = false
     imageView.contentMode = .scaleAspectFit
     return imageView
     }()*/
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    func handleLoginRegisterChange() {
        
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        
        loginRegisterButton.setTitle(title, for: .normal)
        
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 170
        
        //customFBButton.frame = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? CGRect(x: 16, y: 540, width: view.frame.width - 32, height: 50) : customFBButton.frame = CGRect(x: 16, y: 500, width: view.frame.width - 32, height: 50)
        
        nameTextFieldHeightAnchor?.isActive = false
        nameTextField.placeholder = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? "" : "Name"
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0: 1/3)
        
        nameTextFieldHeightAnchor?.isActive = true
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //change background Color
        view.backgroundColor = UIColor(r: 255, g: 255, b: 255)
        
        view.addSubview(customFBButton)
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        //view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupLoginRegisterSegmentedControl()
        setupFBButton()
        
        
    }
    
    func handleCustomFBLogin() {
        
        print("facebook!!")
    }
    
    
    func setupLoginRegisterSegmentedControl() {
        //need x, y, width, height constraints
        
        loginRegisterSegmentedControl.subviews[0].tintColor = UIColor(r:160, g:15, b:16)
        
        loginRegisterSegmentedControl.subviews[1].tintColor = UIColor(r:160, g:15, b:16)
        
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    
    func setupFBButton() {
        
        customFBButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        customFBButton.topAnchor.constraint(equalTo: loginRegisterButton.bottomAnchor, constant: 12).isActive = true
        customFBButton.widthAnchor.constraint(equalTo: loginRegisterButton.widthAnchor).isActive = true
        customFBButton.heightAnchor.constraint(equalTo: loginRegisterButton.heightAnchor).isActive = true
    }
    
    
    
    func setupLoginRegisterButton() {
        
        //view.backgroundColor = UIColor(r: 22, g: 94, b: 233)
        // need x, y, width, height constraints
        let btn = loginRegisterButton
        btn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        btn.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        
        btn.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
    }
    
    
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    
    func setupInputsContainerView() {
        
        
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        //need x, y, width, height constraints
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        
        emailTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        
    }
    
    
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
