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

func getStudentLocations(completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
    
    /* 1/2/3. Set the parameters, Build the URL, Configure the request */
    var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt")!)
    request.addValue(Constants.UdacityParameterValues.ApplicationID, forHTTPHeaderField: Constants.UdacityParameterKeys.ApplicationIDKey)
    request.addValue(Constants.UdacityParameterValues.ApiKeyValue, forHTTPHeaderField: Constants.UdacityParameterKeys.ApiKey)
    
    /* 4. Make the request */
    let session = URLSession.shared
    let task = session.dataTask(with: request) { data, response, error in
        
        // Guard: was there an error?
        guard (error == nil) else {
            completionHandler(false, "There was an error getting student locations: \(String(describing: error))")
            return
        }
        // Guard: Is there a succesful HTTP 2XX response?
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            completionHandler(false, "Your request returned a status code other than 2xx!")
            return
        }
        // Guard: any data returned?
        guard let data = data else {
            completionHandler(false, "No student locations data was returned!")
            return
        }
        
        /* 5. Parse the data */
        let parsedResult: [String:AnyObject]!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
        } catch {
            completionHandler(false, "Could not parse student locations data as JSON")
            return
        }
        
        /* 6. Use the data */
        
        guard let rawStudentLocations = parsedResult["results"] as? [[String: AnyObject]] else {
            completionHandler(false, "Cannot find key 'results' in student locations")
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
        
        StudentModel.Students = studentLocations
        completionHandler(true, nil)
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
            completionHandler(false, "No login data was returned!")
            return
        }
        
        let range = Range(5..<data.count)
        let newData = data.subdata(in: range) /* subset response data! */
        
        /* 5. Parse the data */
        let parsedResult: [String:AnyObject]!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
        } catch {
            completionHandler(false, "Could not parse the login data as JSON")
            return
        }
        
        /* 6. Use the data */
        
        guard let account = parsedResult["account"] as? [String: AnyObject] else {
            completionHandler(false, "Cannot find key 'account' in login parsed results")
            return
        }
        
        Constants.UdacityResponseValues.AccountKey = account["key"] as! String
        completionHandler(true, nil)
    }
    task.resume()
}

func GetPublicUserData(completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
    let request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/\(Constants.UdacityResponseValues.AccountKey)")!)
    
    // Make the request
    
    let session = URLSession.shared
    let task = session.dataTask(with: request) { data, response, error in
        
        // Guard: was there an error?
        guard (error == nil) else {
            completionHandler(false, "There was an error getting User Data: \(String(describing: error))")
            return
        }
        // Guard: Is there a succesful HTTP 2XX response?
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            completionHandler(false, "Your request returned a status code other than 2xx!")
            return
        }
        // Guard: any data returned?
        guard let data = data else {
            completionHandler(false, "No User Data was returned!")
            return
        }
        
        /* 5. Parse the data */
        let range = Range(5..<data.count)
        let newData = data.subdata(in: range) /* subset response data! */
        
        let parsedResult: [String:AnyObject]!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
        } catch {
            completionHandler(false, "Could not parse the User Data")
            return
        }
        
        /* 6. Use the data */
        guard let user = parsedResult["user"] as? [String: AnyObject] else {
            completionHandler(false, "Cannot find key 'user' in User Data")
            return
        }
        
        StudentModel.StudentInformation.LastName = user["last_name"] as! String
        StudentModel.StudentInformation.FirstName = user["first_name"] as! String
        completionHandler(true, nil)
    }
    task.resume()
}

func checkIfStudentIsOnTheMap(completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
    let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(Constants.UdacityResponseValues.AccountKey)%22%7D"
    let url = URL(string: urlString)
    var request = URLRequest(url: url!)
    request.addValue(Constants.UdacityParameterValues.ApplicationID, forHTTPHeaderField: Constants.UdacityParameterKeys.ApplicationIDKey)
    request.addValue(Constants.UdacityParameterValues.ApiKeyValue, forHTTPHeaderField: Constants.UdacityParameterKeys.ApiKey)
    /* 4. Make the request */
    let session = URLSession.shared
    let task = session.dataTask(with: request) { data, response, error in
        
        // Guard: was there an error?
        guard (error == nil) else {
            completionHandler(false, "There was an error with checking if student is on the map: \(String(describing: error))")
            return
        }
        // Guard: Is there a succesful HTTP 2XX response?
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            completionHandler(false, "Your request returned a status code other than 2xx!")
            return
        }
        // Guard: any data returned?
        guard let data = data else {
            completionHandler(false, "No checking if student is on the map data was returned!")
            return
        }
        
        /* 5. Parse the data */
        let parsedResult: [String:AnyObject]!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
        } catch {
            completionHandler(false, "Could not parse the checking if student is on the map data as JSON'")
            return
        }
        
        /* 6. Use the data */
        
        guard let results = parsedResult["results"] as? [[String: AnyObject]] else {
            completionHandler(false, "Cannot find key 'results' in checking if student is on the map parsed results")
            return
        }
        
        if results.isEmpty == true {
            StudentModel.StudentInformation.IsOnTheMap = false
            return
        } else {
            StudentModel.StudentInformation.IsOnTheMap = true
            let student = results[0] as [String: AnyObject]
            StudentModel.StudentInformation.ObjectId = student["objectId"] as! String
        }
        completionHandler(true, nil)
    }
    task.resume()
}

func postNewStudentLocation(completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
    var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
    request.httpMethod = "POST"
    request.addValue(Constants.UdacityParameterValues.ApplicationID, forHTTPHeaderField: Constants.UdacityParameterKeys.ApplicationIDKey)
    request.addValue(Constants.UdacityParameterValues.ApiKeyValue, forHTTPHeaderField: Constants.UdacityParameterKeys.ApiKey)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = "{\"uniqueKey\": \"\(Constants.UdacityResponseValues.AccountKey)\", \"firstName\": \"\(StudentModel.StudentInformation.FirstName)\", \"lastName\": \"\(StudentModel.StudentInformation.LastName)\",\"mapString\": \"\(StudentModel.StudentInformation.MapString)\", \"mediaURL\": \"\(StudentModel.StudentInformation.MediaURL)\",\"latitude\": \(StudentModel.StudentInformation.Latitude), \"longitude\": \(StudentModel.StudentInformation.Longitude)}".data(using: .utf8)
    let session = URLSession.shared
    let task = session.dataTask(with: request) { data, response, error in
        
        // Guard: was there an error?
        guard (error == nil) else {
            completionHandler(false, "There was an error posting new student location: \(String(describing: error))")
            return
        }
        // Guard: Is there a succesful HTTP 2XX response?
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            completionHandler(false, "Your request returned a status code other than 2xx! Code# \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
            return
        }
        // Guard: any data returned?
        guard let data = data else {
            completionHandler(false, "No posting new student location data was returned!")
            return
        }
        completionHandler(true, nil)
    }
    task.resume()
}

func updateStudentLocation(completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
    let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(StudentModel.StudentInformation.ObjectId)"
    let url = URL(string: urlString)
    var request = URLRequest(url: url!)
    request.httpMethod = "PUT"
    request.addValue(Constants.UdacityParameterValues.ApplicationID, forHTTPHeaderField: Constants.UdacityParameterKeys.ApplicationIDKey)
    request.addValue(Constants.UdacityParameterValues.ApiKeyValue, forHTTPHeaderField: Constants.UdacityParameterKeys.ApiKey)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = "{\"uniqueKey\": \"\(Constants.UdacityResponseValues.AccountKey)\", \"firstName\": \"\(StudentModel.StudentInformation.FirstName)\", \"lastName\": \"\(StudentModel.StudentInformation.LastName)\",\"mapString\": \"\(StudentModel.StudentInformation.MapString)\", \"mediaURL\": \"\(StudentModel.StudentInformation.MediaURL)\",\"latitude\": \(StudentModel.StudentInformation.Latitude), \"longitude\": \(StudentModel.StudentInformation.Longitude)}".data(using: .utf8)
    
    /* 4. Make the request */
    let session = URLSession.shared
    let task = session.dataTask(with: request) { data, response, error in
        
        // Guard: was there an error?
        guard (error == nil) else {
            completionHandler(false, "There was an error updating student location: \(String(describing: error))")
            return
        }
        // Guard: Is there a succesful HTTP 2XX response?
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            completionHandler(false, "Your request returned a status code other than 2xx! Code# \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
            return
        }
        // Guard: any data returned?
        guard let data = data else {
            completionHandler(false, "No updating student location data was returned!")
            return
        }
        completionHandler(true, nil)
    }
    task.resume()
}


