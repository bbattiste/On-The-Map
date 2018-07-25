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
        
//        GetPublicUserData()
//        checkIfStudentIsOnTheMap()
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func GetPublicUserData() {
        let request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/\(Constants.UdacityResponseValues.AccountKey)")!)
        
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
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(newData)'")
                return
            }
            
            /* 6. Use the data */
            guard let user = parsedResult["user"] as? [String: AnyObject] else {
                displayError("Cannot find key 'user' in \(parsedResult)")
                return
            }
            
            Constants.ParseResponseValues.LastName = user["last_name"] as! String
            Constants.ParseResponseValues.FirstName = user["first_name"] as! String
        }
        task.resume()
    }
    
    func checkIfStudentIsOnTheMap() {
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
            
            if results.isEmpty == true {
                print("no results")
                Constants.ParseResponseValues.IsOnTheMap = false
                return
            } else {
                print("yes array")
                Constants.ParseResponseValues.IsOnTheMap = true
                let student = results[0] as [String: AnyObject]
                Constants.ParseResponseValues.ObjectId = student["objectId"] as! String
            }
        }
        task.resume()
    }
    
    //TODO: Get lat/long func to work to get coordinates for this func
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
    
//    TODO: ****
    @IBAction func getLatLong() {
        
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.locationTextField.text!) { (placemark, error) in
            
            // if error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
            }
            
            // Guard: was there an error?
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            guard let location = placemark else {
                displayError("No placemark")
                return
            }
            
            print(String(describing: location))
            
            var coordinateParse: CLLocation?
            
            coordinateParse = location.first?.location
            print("coordinatesLat: \(coordinateParse!)")
            
            if let coordinateParse = coordinateParse {
                let coordinates = coordinateParse.coordinate
                Constants.ParseResponseValues.Latitude = coordinates.latitude
                Constants.ParseResponseValues.Longitude = coordinates.longitude
                print("Constants.ParseResponseValues.Latitude: \(Constants.ParseResponseValues.Latitude)")
                print("Constants.ParseResponseValues.Longitude: \(Constants.ParseResponseValues.Longitude)")
            } else {
                displayError("No Matching Location Found")
            }
        }
    }
    
    //TODO: Alert View: look at MemeMe app
}



