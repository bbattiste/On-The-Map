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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createAnnotations()
        
    }

    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
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
    
    
    // TODO: add pin customizing/ use is OnMap or not to post or put
    
    
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
