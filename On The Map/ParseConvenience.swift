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
    func getStudentLocations(completionHandler: (result: [StudentLocations]?, errorString: NSError?) -> Void) {
        println("Running getStudentLocations")

        let parameters = [
            "limit": 100,
            "order": "-updatedAt"
        ]

        ParseClient.sharedInstance().taskForGETMethod(ParseClient.Methods.GETStudentLocations, parameters: parameters) { result, error in
            if let error = error {
                completionHandler(result: nil, errorString: error)
            } else {
                if let locationsData = result["results"] as? [[String: AnyObject]] {
                    let locations = StudentLocations.locationsFromResults(locationsData)
                    completionHandler(result: locations, errorString: nil)
                } else {
                    let errorMessage = "Student Locations not in correct format"
                    let errorDetails = NSError(domain: errorMessage, code: 100, userInfo: [
                        NSLocalizedDescriptionKey : errorMessage
                        ])
                    completionHandler(result: nil, errorString: errorDetails)
                }
            }
        }
    }

    // Skip the first 100 (since they are already loaded), then load the rest. If there were thousands of records, then would change this function to download 100 at a time, over time.
    func getRestOfStudentLocations(completionHandler: (result: [StudentLocations]?, errorString: NSError?) -> Void) {
        println("Running getRestOfStudentLocations")
        let parameters = [
            "skip": 100,
            "order": "-updatedAt"
        ]

        ParseClient.sharedInstance().taskForGETMethod(ParseClient.Methods.GETStudentLocations, parameters: parameters) { result, error in
            if let error = error {
                completionHandler(result: nil, errorString: error)
            } else {
                if let locationsData = result["results"] as? [[String: AnyObject]] {
                    let locations = StudentLocations.locationsFromResultsInsert(locationsData)
                    completionHandler(result: locations, errorString: nil)
                } else {
                    let errorMessage = "Student Locations not in correct format"
                    let errorDetails = NSError(domain: errorMessage, code: 100, userInfo: [
                        NSLocalizedDescriptionKey : errorMessage
                        ])
                    completionHandler(result: nil, errorString: errorDetails)
                }
            }
        }
    }

    func createStudentLocation(jsonBody: [String: AnyObject], completionHandler: (success: Bool, error: NSError?)-> Void) {
        let parameters = ["":""]

        ParseClient.sharedInstance().taskForPOSTMethod(ParseClient.Methods.POSTStudentLocations, parameters: parameters, jsonBody: jsonBody) { result, error in
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    if let created = result["createdAt"] as? String {
                        completionHandler(success: true, error: nil)
                    } else {
                        let errorMessage = result["error"] as! String
                        let errorDetails = NSError(domain: errorMessage, code: 100, userInfo: [
                            NSLocalizedDescriptionKey : errorMessage
                            ])
                        completionHandler(success: false, error: errorDetails)
                    }
                }
            }
        }
    }

    func queryStudentLocation(completionHandler: (result: Bool, errorString: NSError?) -> Void) {

        let parameters = [
            "where" : "{\"uniqueKey\":\"\(UdacityClient.Constants.UserID!)\"}"
        ]

        ParseClient.sharedInstance().taskForGETMethod(ParseClient.Methods.QUERYStudentLocations, parameters: parameters) { result, error in
            if let error = error {
                completionHandler(result: false, errorString: error)
            } else {
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
                    completionHandler(result: false, errorString: error)
                }
            }
        }
    }

    func updateStudentLocation(objectID: String, parameters: [String: AnyObject], completionHandler: (success: Bool, error: NSError?) -> Void) {
        ParseClient.sharedInstance().taskForPUTMethod(ParseClient.Methods.PUTStudentLocation, objectID: objectID, parameters: parameters) { success, error in
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                completionHandler(success: true, error: nil)
            }
        }
    }

    func deleteStudentLocation(objectID: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        ParseClient.sharedInstance().taskForDELETEMethod(objectID) { success, error in
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                completionHandler(success: true, error: nil)
            }
        }
    }

}