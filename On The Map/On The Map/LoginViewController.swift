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
    
    private func getRequestToken() {
        
        /* 1. Set the parameters */
//        let methodParameters = [
//            
//        
//        ]
        
        
    }

    
    
    
}
