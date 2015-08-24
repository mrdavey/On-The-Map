//
//  parseClient.swift
//  On The Map
//
//  Created by David Truong on 10/07/2015.
//  Copyright (c) 2015 David Truong. All rights reserved.
//

import Foundation

class ParseClient: NSObject {

    var session: NSURLSession

    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - GET
    func taskForGETMethod(method: String, parameters: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        // Setting parameters
        var mutableParameters = parameters

        // Build URL and and configure request
        let urlString = Constants.BaseURL + method + Helpers.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

        // Make the request
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in

            // Parse and use the data
            if let error = downloadError {
                completionHandler(result: nil, error: error)
            } else {
                Helpers.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }

        // Start the request
        task.resume()

        return task
    }


    // MARK: - PUT
    func taskForPUTMethod(method: String, objectID: String, parameters: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        // Build URL and and configure request
        let urlString = Constants.BaseURL + method + objectID
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        println(url)
        request.HTTPMethod = "PUT"
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: &jsonifyError)

        // Make the request
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in

            // Parse and use the data
            if let error = downloadError {
                completionHandler(result: nil, error: error)
            } else {
                Helpers.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }

        // Start the request
        task.resume()
        
        return task
    }

    //MARK: - POST
    func taskForPOSTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        // Setting parameters
        var mutableParameters = parameters

        // Build the URL and configure the request
        let urlString = Constants.BaseURL + method + Helpers.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)

        // Make the request
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in

            // Parse the data and use the data
            if let error = downloadError {
                completionHandler(result: nil, error: downloadError)
            } else {
                Helpers.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }

        // Start the request
        task.resume()

        return task
    }

    // MARK: - DELETE
    func taskForDELETEMethod(objectId: String, completionHandler: (success:Bool, error: String?) -> Void) -> NSURLSessionDataTask {
        let urlString = Constants.BaseURL + Methods.PUTStudentLocation + objectId
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)

        request.HTTPMethod = "DELETE"
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                completionHandler(success: false, error: "\(error)")
            } else {
                println("Data: \(data)")
                println("Response: \(response)")
                completionHandler(success: true, error: nil)
            }
        }
        task.resume()

        return task
        
    }


    

    // MARK: - Shared Instance

    class func sharedInstance() -> ParseClient {

        struct Singleton {
            static var sharedInstance = ParseClient()
        }

        return Singleton.sharedInstance
    }
}