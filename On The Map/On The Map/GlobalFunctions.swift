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
            displayError("Your request returned a status code other than 2xx!")
            return
        }
        // Guard: any data returned?
        guard let data = data else {
            displayError("No data was returned!")
            return
        }
        
        let range = Range(5..<data.count)
        let newData = data.subdata(in: range) /* subset response data! */
        print(String(data: newData, encoding: .utf8)!)
        print("***Logout Success***")
    }
    task.resume()
}


