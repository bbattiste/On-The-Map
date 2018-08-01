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
        if StudentModel.StudentInformation.IsOnTheMap {
            updateStudentLocation() { (success, error) in
                if success {
                    // Proceed
                } else {
                    performUIUpdatesOnMain {
                        self.displayError(error!)
                    }
                }
            }
        } else {
            postNewStudentLocation() { (success, error) in
                if success {
                    // Proceed
                } else {
                    performUIUpdatesOnMain {
                        self.displayError(error!)
                    }
                }
            }
        }
        
        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func displayError(_ error: String) {
        let alert = UIAlertController(title: "Alert", message: "\(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Vars/Lets
    let pinLocation = CLLocation(latitude: StudentModel.StudentInformation.Latitude, longitude: StudentModel.StudentInformation.Longitude)
    
    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        activityIndicatorCoord.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
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
        
        
            let lat = CLLocationDegrees(StudentModel.StudentInformation.Latitude)
            let long = CLLocationDegrees(StudentModel.StudentInformation.Longitude)
        
            // Lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
            let first = StudentModel.StudentInformation.FirstName
            let last = StudentModel.StudentInformation.LastName
            let mediaURL = StudentModel.StudentInformation.MediaURL
        
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

}
