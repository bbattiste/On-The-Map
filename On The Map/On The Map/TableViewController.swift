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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //MARK: NAV BAR buttons
        
        // Use plus sign for the add location nav button
        let addPinButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem(rawValue: 4)!, target: self, action: #selector(TableViewController.addPin))
        
        // Create refresh button:
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem(rawValue: 13)!, target: self, action: #selector(TableViewController.viewDidLoad))
        
        // Add refresh and addPin buttons to right nav bar
        self.navigationItem.rightBarButtonItems = [addPinButton, refreshButton]
        
        //TODO: link logout with removing all nav stacks
        // create/Add Logout button to left nav bar:
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LOGOUT", style: UIBarButtonItemStyle(rawValue: 2)!, target: self, action: #selector(TableViewController.logOut))
    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    
//    @objc func getStudentLocations() -> [[String: AnyObject]] {
//
//        var locations = [[String: AnyObject]]()
//
//        /* 1/2/3. Set the parameters, Build the URL, Configure the request */
//        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=5")!)
//        request.addValue(Constants.UdacityParameterValues.ApplicationID, forHTTPHeaderField: Constants.UdacityParameterKeys.ApplicationIDKey)
//        request.addValue(Constants.UdacityParameterValues.ApiKeyValue, forHTTPHeaderField: Constants.UdacityParameterKeys.ApiKey)
//
//        /* 4. Make the request */
//        let session = URLSession.shared
//        let task = session.dataTask(with: request) { data, response, error in
//
//            // if error occurs, print it and re-enable the UI
//            func displayError(_ error: String) {
//                print(error)
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
//            /* 5. Parse the data */
//            let parsedResult: [String:AnyObject]!
//            do {
//                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
//            } catch {
//                displayError("Could not parse the data as JSON: '\(data)'")
//                return
//            }
//
//            /* 6. Use the data */
//
//            guard let studentLocations = parsedResult["results"] as? [[String: AnyObject]] else {
//                displayError("Cannot find key 'results' in \(parsedResult)")
//                return
//            }
//            locations = studentLocations
//
//        }
//        task.resume()
//        return locations
//    }
    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("test 4 self.locations.count: \(Constants.ParseResponseValues.Students.count)")
        return Constants.ParseResponseValues.Students.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("test 5 CELL FOR ROW AT CALLED")
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        let student = Constants.ParseResponseValues.Students[(indexPath as NSIndexPath).row]

        
//        let testFirstName = student["firstName"]
//        let testLastName = student["lastName"]
        //if testFirstName != nil || testLastName != nil {
            let first = student["firstName"] as! String
            let last = student["lastName"] as! String
            let mediaURL = student["mediaURL"] as! String
        //}
        
        // Configure the cell...
        cell.textLabel?.text = "\(first) \(last)"
        
        // If the cell has a detail label, give URL???
        if let detailTextLabel = cell.detailTextLabel {
            detailTextLabel.text = mediaURL
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        UIApplication.shared.open(URL(string : "https://auth.udacity.com/sign-up")!, options: [:], completionHandler: { (status) in
        })
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        
        let goToLoginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        
        // Pass the created instance to current navigation stack
        present(goToLoginViewController, animated: true, completion: nil)
    }
}
