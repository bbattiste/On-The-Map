//
//  StudentModel.swift
//  On The Map
//
//  Created by Bryan's Air on 8/1/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class StudentModel: Codable {
    static var Students = [[String: AnyObject]]()

    // MARK: Parse Response Values "StudentInformation"
    struct StudentInformation: Codable {
        static var previousPinArray = [MKPointAnnotation]()
        static var FirstName = ""
        static var LastName = ""
        static var MapString = ""
        static var MediaURL = ""
        static var Latitude: Double = 0
        static var Longitude: Double = 0
        static var ObjectId = ""
        static var IsOnTheMap = false
    }
}
