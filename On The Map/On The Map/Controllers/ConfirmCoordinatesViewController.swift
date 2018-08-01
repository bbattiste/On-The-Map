//
//  ConfirmCoordinatesViewController.swift
//  On The Map
//
//  Created by Bryan's Air on 7/25/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class ConfirmCoordinatesViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicatorCoord: UIActivityIndicatorView!
    
    // MARK: Actions
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func submit() {
        if Constants.StudentInformation.IsOnTheMap {
            self.updateStudentLocation()
        } else {
            self.postNewStudentLocation()
        }
        
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Vars/Lets
    let pinLocation = CLLocation(latitude: Constants.StudentInformation.Latitude, longitude: Constants.StudentInformation.Longitude)
    
    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.activityIndicatorCoord.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        activityIndicatorCoord.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        createAnnotations()
        mapView.showsUserLocation = true
        centerMapOnLocation(location: pinLocation)
        activityIndicatorCoord.stopAnimating()
    }
    
    // Configure zoom on pinLocation
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 2000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func createAnnotations() {
        
        // create an MKPointAnnotation for each dictionary
        var annotations = [MKPointAnnotation]()
        
        
            let lat = CLLocationDegrees(Constants.StudentInformation.Latitude)
            let long = CLLocationDegrees(Constants.StudentInformation.Longitude)
        
            // Lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
            let first = Constants.StudentInformation.FirstName
            let last = Constants.StudentInformation.LastName
            let mediaURL = Constants.StudentInformation.MediaURL
        
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
        }
    }
    
    // The following code is to make visual changes to the pin: Is incomplete, but can come back to if needed
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        let reuseId = "pin"
//
//        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
//
//        if pinView == nil {
//            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//            pinView!.canShowCallout = true
//            pinView!.pinTintColor = .red
//            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        }
//        else {
//            pinView!.annotation = annotation
//        }
//
//        return pinView
//    }
    
    func postNewStudentLocation() {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue(Constants.UdacityParameterValues.ApplicationID, forHTTPHeaderField: Constants.UdacityParameterKeys.ApplicationIDKey)
        request.addValue(Constants.UdacityParameterValues.ApiKeyValue, forHTTPHeaderField: Constants.UdacityParameterKeys.ApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(Constants.UdacityResponseValues.AccountKey)\", \"firstName\": \"\(Constants.StudentInformation.FirstName)\", \"lastName\": \"\(Constants.StudentInformation.LastName)\",\"mapString\": \"\(Constants.StudentInformation.MapString)\", \"mediaURL\": \"\(Constants.StudentInformation.MediaURL)\",\"latitude\": \(Constants.StudentInformation.Latitude), \"longitude\": \(Constants.StudentInformation.Longitude)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            func displayError(_ error: String) {
                let alert = UIAlertController(title: "Alert", message: "Error: Posting of Location has failed", preferredStyle: .alert)
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
                displayError("Your request returned a status code other than 2xx! Code# \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                return
            }
            // Guard: any data returned?
            guard let data = data else {
                displayError("No data was returned!")
                return
            }
        }
        task.resume()
    }
    
    func updateStudentLocation() {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(Constants.StudentInformation.ObjectId)"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.addValue(Constants.UdacityParameterValues.ApplicationID, forHTTPHeaderField: Constants.UdacityParameterKeys.ApplicationIDKey)
        request.addValue(Constants.UdacityParameterValues.ApiKeyValue, forHTTPHeaderField: Constants.UdacityParameterKeys.ApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(Constants.UdacityResponseValues.AccountKey)\", \"firstName\": \"\(Constants.StudentInformation.FirstName)\", \"lastName\": \"\(Constants.StudentInformation.LastName)\",\"mapString\": \"\(Constants.StudentInformation.MapString)\", \"mediaURL\": \"\(Constants.StudentInformation.MediaURL)\",\"latitude\": \(Constants.StudentInformation.Latitude), \"longitude\": \(Constants.StudentInformation.Longitude)}".data(using: .utf8)
        
        /* 4. Make the request */
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            func displayError(_ error: String) {
                let alert = UIAlertController(title: "Alert", message: "Error: Posting of Location has failed", preferredStyle: .alert)
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
                displayError("Your request returned a status code other than 2xx! Code# \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                return
            }
            // Guard: any data returned?
            guard let data = data else {
                displayError("No data was returned!")
                return
            }
        }
        task.resume()
    }
}
