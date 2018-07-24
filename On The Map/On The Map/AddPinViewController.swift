//
//  AddPinViewController.swift
//  On The Map
//
//  Created by Bryan's Air on 7/3/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//

// Use for easy access in debugging: Battiste1313@gmail.com

import UIKit
import MapKit

class AddPinViewController: UIViewController {

    //MARK: outlets and variables
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.isHidden = false
        getOneStudentLocation()
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func getOneStudentLocation() {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(Constants.UdacityResponseValues.AccountKey)%22%7D"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.addValue(Constants.UdacityParameterValues.ApplicationID, forHTTPHeaderField: Constants.UdacityParameterKeys.ApplicationIDKey)
        request.addValue(Constants.UdacityParameterValues.ApiKeyValue, forHTTPHeaderField: Constants.UdacityParameterKeys.ApiKey)
        /* 4. Make the request */
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            // if error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
            }
            
            // Guard: was there an error?
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                return
            }
            // Guard: Is there a succesful HTTP 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            // Guard: any data returned?
            guard let data = data else {
                displayError("No data was returned!")
                return
            }
            
            /* 5. Parse the data */
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* 6. Use the data */
            
            guard let results = parsedResult["results"] as? [[String: AnyObject]] else {
                displayError("Cannot find key 'results' in \(parsedResult)")
                return
            }
            
            print(results)
            
            //*****TODO: Why is a newstudent not getting info on this app
            
            if results.isEmpty == true {
                print("no results")
                return
            } else {
                print("yes array")
            }
            let student = results[0] as [String: AnyObject]
            
            Constants.ParseResponseValues.FirstName = student["firstName"] as! String
            Constants.ParseResponseValues.LastName = student["lastName"] as! String
            Constants.ParseResponseValues.ObjectId = student["objectId"] as! String
            
            self.updateStudentLocation()
        }
        task.resume()
    }
    
    func updateStudentLocation() {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(Constants.ParseResponseValues.ObjectId)"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue(Constants.UdacityParameterValues.ApplicationID, forHTTPHeaderField: Constants.UdacityParameterKeys.ApplicationIDKey)
        request.addValue(Constants.UdacityParameterValues.ApiKeyValue, forHTTPHeaderField: Constants.UdacityParameterKeys.ApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(Constants.UdacityResponseValues.AccountKey)\", \"firstName\": \"\(Constants.ParseResponseValues.FirstName)\", \"lastName\": \"\(Constants.ParseResponseValues.LastName)\",\"mapString\": \"Cupertino, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.322998, \"longitude\": -122.032182}".data(using: .utf8)
        
        /* 4. Make the request */
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            // if error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
            }
            
            // Guard: was there an error?
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                return
            }
            // Guard: Is there a succesful HTTP 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx! Code# \((response as? HTTPURLResponse)?.statusCode)")
                return
            }
            // Guard: any data returned?
            guard let data = data else {
                displayError("No data was returned!")
                return
            }
            
            print(String(data: data, encoding: .utf8)!)
            
            
            
        }
        task.resume()
    }
    
    //TODO: ****
    func getLatLong() {
        CLGeocoder.geocodeAddressString(<#T##CLGeocoder#>)
    }
    
    
}



