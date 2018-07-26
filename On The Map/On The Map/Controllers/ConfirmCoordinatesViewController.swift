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
        self.mapView.addAnnotations(annotations)
    }
    
    // This changes changes the view of the pin and mediaURL
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "addPin"
        
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
    
    
    // TODO: add pin customizing/ touch on website to follow link: NOT WORKING/ cancel button name to back: and to pop view maybe versus go to view
    

}
