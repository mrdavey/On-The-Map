//
//  ParseConvenience.swift
//  On The Map
//
//  Created by David Truong on 10/07/2015.
//  Copyright (c) 2015 David Truong. All rights reserved.
//

import Foundation

extension ParseClient {

    // Load location data
    func getStudentLocations(completionHandler: (result: [StudentLocations]?, errorString: String?) -> Void) {
        println("Running getStudentLocations")
        let parameters = [
            "limit": 100,
            "order": "-createdAt"
        ]

        ParseClient.sharedInstance().taskForGETMethod(ParseClient.Methods.GETStudentLocations, parameters: parameters) { result, error in
            if let error = error {
                completionHandler(result: nil, errorString: "Student Location download error")
            } else {
                if let locationsData = result["results"] as? [[String: AnyObject]] {
                    let locations = StudentLocations.locationsFromResults(locationsData)
                    completionHandler(result: locations, errorString: nil)
                } else {
                    completionHandler(result: nil, errorString: "Student Locations not in correct format\n\(result)")
                }
            }
        }
    }

    // Skip the first 100 (since they are already loaded), then load the rest. If there were thousands of records, then would change this function to download 100 at a time, over time.
    func getRestOfStudentLocations(completionHandler: (result: [StudentLocations]?, errorString: String?) -> Void) {
        println("Running getRestOfStudentLocations in background")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let parameters = [
                "skip": 100,
                "order": "-createdAt"
            ]

            ParseClient.sharedInstance().taskForGETMethod(ParseClient.Methods.GETStudentLocations, parameters: parameters) { result, error in
                if let error = error {
                    completionHandler(result: nil, errorString: "Student Location download error \(error)")
                } else {
                    if let locationsData = result["results"] as? [[String: AnyObject]] {
                        let locations = StudentLocations.locationsFromResults(locationsData)
                        completionHandler(result: locations, errorString: nil)
                        println("Extra student locations loaded in BG: \(locations.count)")
                    } else {
                        completionHandler(result: nil, errorString: "Student Locations not in correct format\n\(result)")
                    }
                }
            }
        }
    }

    func createStudentLocation(jsonBody: [String: AnyObject], completionHandler: (success: Bool, error: String?)-> Void) {
        let parameters = ["":""]

        ParseClient.sharedInstance().taskForPOSTMethod(ParseClient.Methods.POSTStudentLocations, parameters: parameters, jsonBody: jsonBody) { result, error in
            if let error = error {
                completionHandler(success: false, error: "POST error: \(error)")
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    if let created = result["createdAt"] as? String {
                        println("\(created)")
                        completionHandler(success: true, error: nil)
                    } else {
                        let errorMessage = result["error"] as! String
                        completionHandler(success: false, error: "JSON result error: \(error)")
                    }
                }
            }
        }
    }

    func queryStudentLocation(completionHandler: (result: Bool, errorString: String?) -> Void) {

        let parameters = [
            "where" : "{\"uniqueKey\":\"\(UdacityClient.Constants.UserID!)\"}"
        ]

        ParseClient.sharedInstance().taskForGETMethod(ParseClient.Methods.QUERYStudentLocations, parameters: parameters) { result, error in
            if let error = error {
                completionHandler(result: false, errorString: "Error: \(error)")
            } else {
                println("Result: \(result)")
                if let usersLocation = result["results"] as? [[String: AnyObject]] {
                    if usersLocation.isEmpty {
                        completionHandler(result: false, errorString: nil)
                    } else {
                        println("Location already exists \(usersLocation)")
                        let firstResult = usersLocation[0] as [String: AnyObject]
                        if let objectID = firstResult["objectId"] as? String {
                            ParseClient.Constants.StudentLocationObjectId = objectID
                            let locations = StudentLocations.locationsFromResults(usersLocation)
                            completionHandler(result: true, errorString: nil)
                        }
                    }
            } else {
                completionHandler(result: false, errorString: "Error: \(result)")
            }
        }
        }
    }

    func updateStudentLocation(objectID: String, parameters: [String: AnyObject], completionHandler: (success: Bool, error: String?) -> Void) {
        ParseClient.sharedInstance().taskForPUTMethod(ParseClient.Methods.PUTStudentLocation, objectID: objectID, parameters: parameters) { success, error in
            if let error = error {
                completionHandler(success: false, error: "Error: \(error)")
            } else {
                completionHandler(success: true, error: nil)
            }
        }
    }

    func deleteStudentLocation(objectID: String, completionHandler: (success: Bool, error: String?) -> Void) {
        ParseClient.sharedInstance().taskForDELETEMethod(objectID) { success, error in
            if let error = error {
                completionHandler(success: false, error: "Error: \(error)")
            } else {
                completionHandler(success: true, error: nil)
            }
        }
    }

}