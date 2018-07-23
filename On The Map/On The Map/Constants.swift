//
//  Constants.swift
//  On The Map
//
//  Created by Bryan's Air on 7/9/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//

// MARK: Constants
struct Constants {
    
    // MARK: Udacity
    struct Udacity {
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api/session"
    }
    
    // MARK: Udacity Parameter Keys
    struct UdacityParameterKeys {
        static let Dictionary = "udacity"
        static let Username = "username"
        static let Password = "password"
        static let ApplicationIDKey = "X-Parse-Application-Id"
        static let ApiKey = "X-Parse-REST-API-Key"
    }
    
    // MARK: Udacity Parameter Values
    struct UdacityParameterValues {
        static let ApiKeyValue = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    }
    
    // MARK: Udacity Response Values
    struct UdacityResponseValues {
        static var AccountKey = "" // Udacity AccountKey is Parse UniqueKey
    }
    
    // MARK: Parse Parameter Values
    struct ParseParameterValues {
        static let UniqueKey = "uniqueKey" // Parse UniqueKey is Udacity AccountKey
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let ObjectId = "objectId"
    }
    
    // MARK: Parse Response Values
    struct ParseResponseValues {
        static var Students = [[String: AnyObject]]()
        static var StudentResults = [[String: AnyObject]]()
        static var FirstName = ""
        static var LastName = ""
        static var MapString = ""
        static var MediaURL = ""
        static var Latitude = 0
        static var Longitude = 0
    }
    
    
    
    static let ObjectId = "objectId"

    static let UniqueKey = "uniqueKey"

    static let FirstName = "firstName"

    static let LastName = "lastName"

    static let MapString = "mapString"

    static let MediaURL = "mediaURL"

    static let Latitude = "latitude"

    static let Longitude = "longitude"

    static let CreatedAt = "createdAt"

    static let UpdatedAt = "updatedAt"


    

}
