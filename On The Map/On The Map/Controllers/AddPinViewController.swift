//
//  AddPinViewController.swift
//  On The Map
//
//  Created by Bryan's Air on 7/3/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//

import UIKit
import MapKit

class AddPinViewController: UIViewController, UITextFieldDelegate {

    //MARK: outlets and variables
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var activityIndicatorAddPin: UIActivityIndicatorView!
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getLatLong() {
        
        activityIndicatorAddPin.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        activityIndicatorAddPin.startAnimating()
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationTextField.text!) { (placemark, error) in
            
            func displayError(_ error: String) {
                let alert = UIAlertController(title: "Alert", message: "Invalid Location", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                self.activityIndicatorAddPin.stopAnimating()
            }
            
            // Guard: was there an error?
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            // Parse placemark results
            guard let location = placemark else {
                displayError("No placemark")
                return
            }
            
            // Store Lat/long/textFields
            self.websiteTextField.text! = self.checkWebsite(website: self.websiteTextField.text!)
            var coordinateParse: CLLocation?
            coordinateParse = location.first?.location
            if let coordinateParse = coordinateParse {
                let coordinates = coordinateParse.coordinate
                StudentModel.StudentInformation.Latitude = coordinates.latitude
                StudentModel.StudentInformation.Longitude = coordinates.longitude
                StudentModel.StudentInformation.MediaURL = self.websiteTextField.text!
                StudentModel.StudentInformation.MapString = self.locationTextField.text!
            }
            
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "ConfirmCoordinatesViewController") as! ConfirmCoordinatesViewController
            self.present(controller, animated: true, completion: nil)
            self.activityIndicatorAddPin.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.isHidden = false
        GetPublicUserData() { (success, error) in
            if success {
                checkIfStudentIsOnTheMap() { (success, error) in
                    if success {
                        // Proceed
                    } else {
                        performUIUpdatesOnMain {
                            self.displayError(error!)
                        }
                    }
                }
            } else {
                performUIUpdatesOnMain {
                    self.displayError(error!)
                }
            }
        }
    }
    
    func displayError(_ error: String) {
        let alert = UIAlertController(title: "Alert", message: "\(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkWebsite(website: String) -> String {
        if website.contains("Enter a Website") || website == "" {
            return "https://www.udacity.com"
        } else if website.contains("https://") || website.contains("http://") {
            return website
        } else if website.contains("www.") {
            let websiteNew = website.replacingOccurrences(of: "www.", with: "https://www.")
            return websiteNew
        } else {
            return "https://www.\(website)"
        }
    }

    // The following code is to add textField options: Is incomplete, will come back to
//    // TextFields to return on enter
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//
//    //  Website textField to include https://
//
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        updateText(textField)
//    }
//
//    func updateText(_ textField: UITextField) {
//        if textField == websiteTextField {
//            if websiteTextField.text == "" {
//                websiteTextField.text = "https://"
//            }
//        }
//    }
    
}



