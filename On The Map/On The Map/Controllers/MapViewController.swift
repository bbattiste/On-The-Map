//
//  MapViewController.swift
//  On The Map
//
//  Created by Bryan's Air on 7/3/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewWillAppear(_ animated: Bool) {
        self.activityIndicatorStart()
        self.getStudentLocations()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //MARK: NAV BAR buttons
        
        // Use plus sign for the add location nav button
        let addPinButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem(rawValue: 4)!, target: self, action: #selector(MapViewController.addPin))
        
        // Create refresh button:
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem(rawValue: 13)!, target: self, action: #selector(MapViewController.viewWillAppear))
        
        // Add refresh and addPin buttons to right nav bar
        self.navigationItem.rightBarButtonItems = [addPinButton, refreshButton]
        
        // create/Add Logout button to left nav bar:
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LOGOUT", style: UIBarButtonItemStyle(rawValue: 2)!, target: self, action: #selector(MapViewController.logOut))
        
        self.activityIndicatorStop()
    }
    
    func getStudentLocations() {
        
        /* 1/2/3. Set the parameters, Build the URL, Configure the request */
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
        request.addValue(Constants.UdacityParameterValues.ApplicationID, forHTTPHeaderField: Constants.UdacityParameterKeys.ApplicationIDKey)
        request.addValue(Constants.UdacityParameterValues.ApiKeyValue, forHTTPHeaderField: Constants.UdacityParameterKeys.ApiKey)
        
        /* 4. Make the request */
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            // if error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                let alert = UIAlertController(title: "Alert", message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
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
                //displayError("Could not parse the data as JSON: '\(data)'")
                displayError("Could not parse the data as JSON")
                return
            }

            /* 6. Use the data */
            
            guard let rawStudentLocations = parsedResult["results"] as? [[String: AnyObject]] else {
                //displayError("Cannot find key 'results' in \(parsedResult)")
                displayError("Cannot find key 'results'")
                return
            }
            
            //TODO?: may want to put in a constant var that decides if incomplete student still gets pin, but will not follow links?
            
            //Check if all data we need is there
            var studentLocations = [[String: AnyObject]]()
            
            for dictionary in rawStudentLocations {
                let testLat = dictionary["latitude"]
                let testLong = dictionary["longitude"]
                let testFirst = dictionary["firstName"]
                let testLast = dictionary["lastName"]
                let testMedia = dictionary["mediaURL"]
                
                if testLat is Double {
                    if testLong is Double {
                        if testFirst is String {
                            if testLast is String {
                                if testMedia is String {
                                    if (testMedia?.contains("https://"))!{
                                        studentLocations.append(dictionary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Constants.ParseResponseValues.Students = studentLocations
            self.createAnnotations(locations: studentLocations)
        }
        task.resume()
    }
    
    func createAnnotations(locations: [[String: AnyObject]]) {
        
        // create an MKPointAnnotation for each dictionary
        var annotations = [MKPointAnnotation]()

        for dictionary in locations {
            
            let lat = CLLocationDegrees(dictionary["latitude"] as! Double)
            let long = CLLocationDegrees(dictionary["longitude"] as! Double)
            
            // Lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = dictionary["firstName"] as! String
            let last = dictionary["lastName"] as! String
            let mediaURL = dictionary["mediaURL"] as! String
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        // clear previous annotations and add the new annotations to the map.
        performUIUpdatesOnMain {
            self.mapView.removeAnnotations(Constants.ParseResponseValues.previousPinArray)
            self.mapView.addAnnotations(annotations)
            Constants.ParseResponseValues.previousPinArray = annotations
            self.viewDidLoad()
        }
        
    }
    
    // This changes changes the view of the pin and mediaURL
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }

        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:]) { (_) in
                }
            }
        }
    }
    
    func activityIndicatorStart() {
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        //UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func activityIndicatorStop() {
        activityIndicator.stopAnimating()
        //UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    //MARK: Go To Add Pin View
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
//        let goToLoginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
//
//        // Pass the created instance to current navigation stack
//        present(goToLoginViewController, animated: true, completion: nil)
    }
}
