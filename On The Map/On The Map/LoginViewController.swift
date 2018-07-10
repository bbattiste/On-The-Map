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
    @IBOutlet weak var passwordTextFIeld: UITextField!
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
    
    private func completeLogin() {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "MapsTabBarController") as! UITabBarController
        self.present(controller, animated: true, completion: nil)
    }
    
    private func postSession() {
        
        /* 1/2/3. Set the parameters, Build the URL, Configure the request */
        
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"\(Constants.UdacityParameterKeys.Dictionary)\": {\"\(Constants.UdacityParameterKeys.Username)\": \"\(usernameTextField.text!)\", \"\(Constants.UdacityParameterKeys.Password)\": \"\(passwordTextFIeld.text!)\"}}".data(using: .utf8)
        
        /* 4. Make the request */
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            // if error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.debugTextLabel.text = "Login Failed (Request Token)."
                }
            }
            
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
        }
        task.resume()
    }

    
    
    
}
