//
//  LoginViewController.swift
//  On The Map
//
//  Created by Saeed Khader on 30/11/2019.
//  Copyright © 2019 Saeed Khader. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    
    // MARK: - UI Properties
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activtyIndicator: UIActivityIndicatorView!
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    
    // MARK: - Login
    
    @IBAction func loginTapped(_ sender: Any) {
        setLoginIn(true)
        UdacityClient.login(username: emailTextField.text ?? "", password: passwordTextField.text ?? "", completion: handleLoginResponse(success:error:))
    }
    
    // MARK: - Sign Up
    
    @IBAction func signUpTapped(_ sender: Any) {
        let app = UIApplication.shared
        app.open(URL(string: "https://auth.udacity.com/sign-up")!)
    }
    
    // MARK: - Handle Response
    
    func handleLoginResponse(success: Bool, error: Error?){
        if success {
            performSegue(withIdentifier: "completeLogin", sender: nil)
            UdacityClient.getPublicUserData { (success, error) in
                print(error ?? "")
            }
        } else {
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
        setLoginIn(false)
    }
    
    // MARK: - Functions
    
    func setLoginIn(_ logginIn: Bool) {
        if logginIn {
            activtyIndicator.startAnimating()
        } else {
            activtyIndicator.stopAnimating()
        }
        emailTextField.isEnabled = !logginIn
        passwordTextField.isEnabled = !logginIn
        loginButton.isEnabled = !logginIn
    }
    
    func showLoginFailure(message: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: self)
    }
    
    // MARK: - TextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEqual(emailTextField) {
            passwordTextField.becomeFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
        }
        return true
    }

    
    
}

