//
//  TableViewController.swift
//  On The Map
//
//  Created by Bryan's Air on 7/3/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//

import UIKit
import Foundation

class TableViewController: UITableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getStudentLocations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: NAV BAR buttons
        
        // Use plus sign for the add location nav button
        let addPinButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem(rawValue: 4)!, target: self, action: #selector(TableViewController.addPin))
        
        // Create refresh button:
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem(rawValue: 13)!, target: self, action: #selector(TableViewController.viewDidLoad))
        
        // Add refresh and addPin buttons to right nav bar
        self.navigationItem.rightBarButtonItems = [addPinButton, refreshButton]
        
        // create/Add Logout button to left nav bar:
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LOGOUT", style: UIBarButtonItemStyle(rawValue: 2)!, target: self, action: #selector(TableViewController.logOut))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.StudentInformation.Students.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        let student = Constants.StudentInformation.Students[(indexPath as NSIndexPath).row]
        
        let first = (student["firstName"] as! String).capitalized
        let last = (student["lastName"] as! String).capitalized
        let mediaURL = student["mediaURL"] as! String
        
        // Configure the cell...
        cell.textLabel?.text = "\(first) \(last)"
        
        // If the cell has a detail label, give URL???
        if let detailTextLabel = cell.detailTextLabel {
            detailTextLabel.text = mediaURL
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let student = Constants.StudentInformation.Students[(indexPath as NSIndexPath).row]
        let mediaURL = student["mediaURL"] as! String
        UIApplication.shared.open(URL(string : mediaURL)!, options: [:], completionHandler: { (status) in
        })
    }
    
    //MARK: Add Pin
    @objc func addPin() {
        // Create a instance of Destination AddPinViewController
        let goToAddPinViewController = storyboard?.instantiateViewController(withIdentifier: "AddPinStoryBoard") as! AddPinViewController
        
        // Pass the created instance to current navigation stack
        present(goToAddPinViewController, animated: true, completion: nil)
    }
    
    @objc func logOut() {
        // Delete Session
        deleteSession()
        self.dismiss(animated: false, completion: nil)
    }
}
