//
//  MapViewController.swift
//  On The Map
//
//  Created by Bryan's Air on 7/3/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//

// Use for easy access in debugging: Battiste1313@gmail.com

import UIKit
import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getStudentLocations()

        //MARK: NAV BAR buttons
        
        // Use plus sign for the add location nav button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem(rawValue: 4)!, target: self, action: #selector(MapViewController.addPin))
        
        //TODO: link logout with removing all nav stacks
        // Logout button:
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LOGOUT", style: UIBarButtonItemStyle(rawValue: 2)!, target: self, action: #selector(MapViewController.logOut))
        
        // TODO // Refresh button:
        //self.navigationItem.rightBarButtonItems //= UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem(rawValue: 13)!, target: self, action: #selector(MapViewController.addPin))
        
    }
    
    // TODO: Random Paginate results
    func getStudentLocations() {
        
        /* 1/2/3. Set the parameters, Build the URL, Configure the request */
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
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
            
            guard let studentLocations = parsedResult["results"] as? [[String: AnyObject]] else {
                displayError("Cannot find key 'results' in \(parsedResult)")
                return
            }
            
            self.createAnnotations(locations: studentLocations)
        }
        task.resume()
    }
    
    func createAnnotations(locations: [[String: AnyObject]]) {
        var annotations = [MKPointAnnotation]()
        
    }
    
    
    
    //MARK: Add Pin
    
    @objc func addPin() {
        // Create a instance of Destination AddPinViewController
        let goToAddPinViewController = storyboard?.instantiateViewController(withIdentifier: "AddPinStoryBoard") as! AddPinViewController
        
        // Pass the created instance to current navigation stack
        present(goToAddPinViewController, animated: true, completion: nil)
    }
    
    @objc func logOut() {
        if let navigationController = navigationController {
            navigationController.popToRootViewController(animated: true)
            print("logout button pressed")
        }
    }
}
