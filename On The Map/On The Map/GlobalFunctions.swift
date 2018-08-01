//
//  GlobalFunctions.swift
//  On The Map
//
//  Created by Bryan's Air on 7/17/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//

import Foundation

func deleteSession() {
    
    /* 1/2/3. Set the parameters, Build the URL, Configure the request */
    
    var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
    request.httpMethod = "DELETE"
    var xsrfCookie: HTTPCookie? = nil
    let sharedCookieStorage = HTTPCookieStorage.shared
    for cookie in sharedCookieStorage.cookies! {
        if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
    }
    if let xsrfCookie = xsrfCookie {
        request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
    }
    
    /* 4. Make the request */
    let session = URLSession.shared
    let task = session.dataTask(with: request) { data, response, error in
        
        func displayError(_ error: String) {
//            TODO
//            let alert = UIAlertController(title: "Alert", message: "Error deleting session \(error)", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
//                NSLog("The \"OK\" alert occured.")
//            }))
//            self.present(alert, animated: true, completion: nil)
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
        
        // Results if needed
        let range = Range(5..<data.count)
        let newData = data.subdata(in: range) /* subset response data! */
    }
    task.resume()
}

func getStudentLocations() {
    
    /* 1/2/3. Set the parameters, Build the URL, Configure the request */
    var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
    request.addValue(Constants.UdacityParameterValues.ApplicationID, forHTTPHeaderField: Constants.UdacityParameterKeys.ApplicationIDKey)
    request.addValue(Constants.UdacityParameterValues.ApiKeyValue, forHTTPHeaderField: Constants.UdacityParameterKeys.ApiKey)
    
    /* 4. Make the request */
    let session = URLSession.shared
    let task = session.dataTask(with: request) { data, response, error in
        
        func displayError(_ error: String) {
//            TODO
//            let alert = UIAlertController(title: "Alert", message: "Error getting student locations \(error)", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
//                NSLog("The \"OK\" alert occured.")
//            }))
//            self.present(alert, animated: true, completion: nil)
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
            displayError("Could not parse the data as JSON: '\(data)'")
            return
        }
        
        /* 6. Use the data */
        
        guard let rawStudentLocations = parsedResult["results"] as? [[String: AnyObject]] else {
            displayError("Cannot find key 'results' in \(parsedResult)")
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
        
        Constants.StudentInformation.Students = studentLocations
    }
    task.resume()
}

func postSession(completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
    
    /* 1/2/3. Set the parameters, Build the URL, Configure the request */
    
    var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = "{\"\(Constants.UdacityParameterKeys.Dictionary)\": {\"\(Constants.UdacityParameterKeys.Username)\": \"\(Constants.UdacityParameterValues.Username)\", \"\(Constants.UdacityParameterKeys.Password)\": \"\(Constants.UdacityParameterValues.Password)\"}}".data(using: .utf8)
    
    /* 4. Make the request */
    let session = URLSession.shared
    let task = session.dataTask(with: request) { data, response, error in
        
        // Guard: was there an error?
        guard (error == nil) else {
            completionHandler(false, "Login Failed")
            return
        }
        
        // Guard: Is there a succesful HTTP 2XX response?
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            if (response as? HTTPURLResponse)?.statusCode == 403 {
                completionHandler(false, "Username or Password Incorrect")
            } else {
                completionHandler(false, "Problems with Connection")
            }
            return
        }
        
        // Guard: any data returned?
        guard let data = data else {
            completionHandler(false, "No data was returned!")
            return
        }
        
        let range = Range(5..<data.count)
        let newData = data.subdata(in: range) /* subset response data! */
        
        /* 5. Parse the data */
        let parsedResult: [String:AnyObject]!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
        } catch {
            completionHandler(false, "Could not parse the data as JSON")
            return
        }
        
        /* 6. Use the data */
        
        guard let account = parsedResult["account"] as? [String: AnyObject] else {
            completionHandler(false, "Cannot find key 'account' in \(parsedResult)")
            return
        }
        
        Constants.UdacityResponseValues.AccountKey = account["key"] as! String
        completionHandler(true, nil)
    }
    task.resume()
}
