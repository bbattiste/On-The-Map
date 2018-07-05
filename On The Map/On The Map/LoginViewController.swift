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
    
    // Link sign up button with
    @IBAction func signUp(_ sender: Any) {
        UIApplication.shared.open(URL(string : "https://auth.udacity.com/sign-up")!, options: [:], completionHandler: { (status) in
        })
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
