//
//  UdacityClient.swift
//  On The Map
//
//  Created by David Truong on 23/08/2015.
//  Copyright (c) 2015 David Truong. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {

    var session: NSURLSession

    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }

    //MARK: - POST
    func taskForPOSTMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        // Build the URL and configure the request
        let urlString = Constants.BaseURL + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &jsonifyError)

        // Make the request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            // Parse the data and use the data
            if let error = downloadError {
                completionHandler(result: nil, error: downloadError)
            } else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) // Skip first 5 characters as per Udacity security check
                Helpers.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }

        // Start the request
        task.resume()
        
        return task
    }

    // MARK: - GET
    func taskForGETMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        // Build URL and and configure request
        let urlString =  UdacityClient.Constants.BaseURL + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        // Make the request
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            // Parse and use the data
            if let error = downloadError {
                completionHandler(result: nil, error: error)
            } else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                Helpers.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }

        // Start the request
        task.resume()
        
        return task
    }


    // MARK: - DELETE
    func taskForDELETEMethod(method: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        // Build URL and and configure request
        let urlString =  UdacityClient.Constants.BaseURL + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-TOKEN")
        }

        // Make the request
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            // Parse and use the data
            if let error = downloadError {
                completionHandler(result: nil, error: error)
            } else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                Helpers.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }

        // Start the request
        task.resume()

        return task
    }


    // MARK: - Shared Instance

    class func sharedInstance() -> UdacityClient {

        struct Singleton {
            static var sharedInstance = UdacityClient()
        }

        return Singleton.sharedInstance
    }

}