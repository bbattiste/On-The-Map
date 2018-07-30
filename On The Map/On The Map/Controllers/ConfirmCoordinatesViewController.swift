//
//  ConfirmCoordinatesViewController.swift
//  On The Map
//
//  Created by Bryan's Air on 7/25/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//
// https://

import UIKit
import Foundation
import MapKit

class ConfirmCoordinatesViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var activityIndicator = UIActivityIndicatorView()
    let pinLocation = CLLocation(latitude: Constants.ParseResponseValues.Latitude, longitude: Constants.ParseResponseValues.Longitude)
    
    override func viewWillAppear(_ animated: Bool) {
        self.activityIndicatorStart()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: set map to pin location
        createAnnotations()
        mapView.showsUserLocation = true
        centerMapOnLocation(location: pinLocation)
        performUIUpdatesOnMain {
            self.activityIndicatorStop()
        }
    }

    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submit() {
        print("Constants.ParseResponseValues.IsOnTheMap: \(Constants.ParseResponseValues.IsOnTheMap)")
        
        if Constants.ParseResponseValues.IsOnTheMap {
            self.updateStudentLocation()
        } else {
            self.postNewStudentLocation()
        }
        
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // Configure zoom on pinLocation
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 2000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
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
    
    func createAnnotations() {
        
        // create an MKPointAnnotation for each dictionary
        var annotations = [MKPointAnnotation]()
        
        
            let lat = CLLocationDegrees(Constants.ParseResponseValues.Latitude)
            let long = CLLocationDegrees(Constants.ParseResponseValues.Longitude)
        
        print("**** lat = \(String(describing: lat)) +++ long = \(String(describing: long))")
        
            // Lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
            let first = Constants.ParseResponseValues.FirstName
            let last = Constants.ParseResponseValues.LastName
            let mediaURL = Constants.ParseResponseValues.MediaURL
        
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
        
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        
        // add the annotations to the map.
        performUIUpdatesOnMain {
            self.mapView.addAnnotations(annotations)
            self.activityIndicatorStop()
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
    
    func postNewStudentLocation() {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue(Constants.UdacityParameterValues.ApplicationID, forHTTPHeaderField: Constants.UdacityParameterKeys.ApplicationIDKey)
        request.addValue(Constants.UdacityParameterValues.ApiKeyValue, forHTTPHeaderField: Constants.UdacityParameterKeys.ApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(Constants.UdacityResponseValues.AccountKey)\", \"firstName\": \"\(Constants.ParseResponseValues.FirstName)\", \"lastName\": \"\(Constants.ParseResponseValues.LastName)\",\"mapString\": \"\(Constants.ParseResponseValues.MapString)\", \"mediaURL\": \"\(Constants.ParseResponseValues.MediaURL)\",\"latitude\": \(Constants.ParseResponseValues.Latitude), \"longitude\": \(Constants.ParseResponseValues.Longitude)}".data(using: .utf8)
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
                displayError("Your request returned a status code other than 2xx! Code# \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
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
    
    func updateStudentLocation() {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(Constants.ParseResponseValues.ObjectId)"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue(Constants.UdacityParameterValues.ApplicationID, forHTTPHeaderField: Constants.UdacityParameterKeys.ApplicationIDKey)
        request.addValue(Constants.UdacityParameterValues.ApiKeyValue, forHTTPHeaderField: Constants.UdacityParameterKeys.ApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(Constants.UdacityResponseValues.AccountKey)\", \"firstName\": \"\(Constants.ParseResponseValues.FirstName)\", \"lastName\": \"\(Constants.ParseResponseValues.LastName)\",\"mapString\": \"\(Constants.ParseResponseValues.MapString)\", \"mediaURL\": \"\(Constants.ParseResponseValues.MediaURL)\",\"latitude\": \(Constants.ParseResponseValues.Latitude), \"longitude\": \(Constants.ParseResponseValues.Longitude)}".data(using: .utf8)
        
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
                displayError("Your request returned a status code other than 2xx! Code# \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
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
}
