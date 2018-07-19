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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    // Link sign up button with
    @IBAction func signUp(_ sender: Any) {
        UIApplication.shared.open(URL(string : "https://auth.udacity.com/sign-up")!, options: [:], completionHandler: { (status) in
        })
    }
    
    // MARK: Login
    
    @IBAction func login(_ sender: AnyObject) {
        debugTextLabel.text = ""
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        }
        //TODO LOGIN: Uncomment
//        postSession()
        completeLogin()
    }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.debugTextLabel.text = ""
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "MapsTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
    // TODO LOGIN: Uncomment
//    private func postSession() {
//
//        /* 1/2/3. Set the parameters, Build the URL, Configure the request */
//
//        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = "{\"\(Constants.UdacityParameterKeys.Dictionary)\": {\"\(Constants.UdacityParameterKeys.Username)\": \"\(usernameTextField.text!)\", \"\(Constants.UdacityParameterKeys.Password)\": \"\(passwordTextField.text!)\"}}".data(using: .utf8)
//
//        /* 4. Make the request */
//        let session = URLSession.shared
//        let task = session.dataTask(with: request) { data, response, error in
//
//            // if error occurs, print it and re-enable the UI
//            func displayError(_ error: String) {
//                print(error)
//                performUIUpdatesOnMain {
//                    self.setUIEnabled(true)
//                    self.debugTextLabel.text = "Login Failed"
//                }
//            }
//
//            // Guard: was there an error?
//            guard (error == nil) else {
//                displayError("There was an error with your request: \(String(describing: error))")
//                return
//            }
//            // Guard: Is there a succesful HTTP 2XX response?
//            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
//                displayError("Your request returned a status code other than 2xx!")
//                return
//            }
//            // Guard: any data returned?
//            guard let data = data else {
//                displayError("No data was returned!")
//                return
//            }
//
//            let range = Range(5..<data.count)
//            let newData = data.subdata(in: range) /* subset response data! */
//            print(String(data: newData, encoding: .utf8)!)
//            self.completeLogin()
//            print("***login success***")
//        }
//        task.resume()
//    }
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
