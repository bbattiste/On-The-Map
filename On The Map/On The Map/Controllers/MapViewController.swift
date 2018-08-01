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
    
    @IBOutlet weak var activityIndicatorMap: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        activityIndicatorMap.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        activityIndicatorMap.startAnimating()
        
        getStudentLocations() { (success, error) in
            if success {
                self.createAnnotations(locations: StudentModel.Students)
            } else {
                performUIUpdatesOnMain {
                    self.displayError(error!)
                    self.activityIndicatorMap.stopAnimating()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //MARK: NAV BAR buttons
        
        // Use plus sign for the add location nav button
        let addPinButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem(rawValue: 4)!, target: self, action: #selector(MapViewController.addPin))
        
        // Create refresh button:
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem(rawValue: 13)!, target: self, action: #selector(MapViewController.viewWillAppear))
        
        // Add refresh and addPin buttons to right nav bar
        navigationItem.rightBarButtonItems = [addPinButton, refreshButton]
        
        // create/Add Logout button to left nav bar:
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LOGOUT", style: UIBarButtonItemStyle(rawValue: 2)!, target: self, action: #selector(MapViewController.logOut))
        
        activityIndicatorMap.stopAnimating()
    }
    
    func displayError(_ error: String) {
        let alert = UIAlertController(title: "Alert", message: "\(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
        self.activityIndicatorMap.stopAnimating()
    }
    
    func createAnnotations(locations: [[String: AnyObject]]) {
        
        // create an MKPointAnnotation for each dictionary
        var annotations = [MKPointAnnotation]()

        for dictionary in locations {
            
            let lat = CLLocationDegrees(dictionary["latitude"] as! Double)
            let long = CLLocationDegrees(dictionary["longitude"] as! Double)
            
            // Lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = (dictionary["firstName"] as! String).capitalized
            let last = (dictionary["lastName"] as! String).capitalized
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
            self.mapView.removeAnnotations(StudentModel.StudentInformation.previousPinArray)
            self.mapView.addAnnotations(annotations)
            StudentModel.StudentInformation.previousPinArray = annotations
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
    }
}
