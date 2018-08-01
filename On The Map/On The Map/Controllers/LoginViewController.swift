//
//  LoginViewController.swift
//  On The Map
//
//  Created by Bryan's Air on 7/2/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {

    // MARK: Outlets and variables
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var debugTextLabel: UILabel!
    
    // Lock phone orientation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .portrait
        }
    }
    
    // Link sign up button with
    @IBAction func signUp(_ sender: Any) {
        UIApplication.shared.open(URL(string : "https://auth.udacity.com/sign-up")!, options: [:], completionHandler: { (status) in
        })
    }
    
    // MARK: Login
    
    @IBAction func login(_ sender: AnyObject) {
        
        self.loginButton.isEnabled = false
        
        debugTextLabel.text = ""
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty"
            self.loginButton.isEnabled = true
            return
        } else {
            Constants.UdacityParameterValues.Username = usernameTextField.text!
            Constants.UdacityParameterValues.Password = passwordTextField.text!
        }
        
        postSession() { (success, error) in
            if success {
                self.completeLogin()
            } else {
                self.displayError(error!)
                self.loginButton.isEnabled = true
            }
        }
    }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.debugTextLabel.text = ""
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "MapsTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
            self.loginButton.isEnabled = true
        }
    }
    
    func displayError(_ error: String){
        performUIUpdatesOnMain {
            self.setUIEnabled(true)
            self.debugTextLabel.text = error
        }
    }

}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    // textfields will return with enter key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // textfields will return with touch on view
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
}
// MARK: - LoginViewController (Configure UI)

private extension LoginViewController {
    
    func setUIEnabled(_ enabled: Bool) {
        usernameTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        debugTextLabel.text = ""
        debugTextLabel.isEnabled = enabled
    }
}
