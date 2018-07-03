//
//  AddPinViewController.swift
//  On The Map
//
//  Created by Bryan's Air on 7/3/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//

import UIKit

class AddPinViewController: UIViewController {

    //MARK: outlets and variables
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.isHidden = false
    }

    
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
}
