//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by David Truong on 23/08/2015.
//  Copyright (c) 2015 David Truong. All rights reserved.
//

import Foundation

extension UdacityClient {

    func loginToUdacity(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        let loginCredentials: [String: AnyObject] = [
            "username" : username,
            "password" : password
        ]

        let parameters = ["udacity" : loginCredentials]

        UdacityClient.sharedInstance().taskForPOSTMethod(UdacityClient.Methods.POSTASession, parameters: parameters) { result, error in
            if let error = error {
                completionHandler(success: false, errorString: "\(error)")
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    if let account = result["account"] as? [String: AnyObject] {
                        if account["registered"] as! Bool == true {
                            println("account registered")
                            UdacityClient.Constants.UserID = account["key"] as? String
                            if let session = result["session"] as? [String: AnyObject] {
                                UdacityClient.Constants.UserSessionID = session["id"] as? String
                            }
                            completionHandler(success: true, errorString: nil)
                        }
                    } else {
                        let errorMessage = result["error"] as! String
                        completionHandler(success: false, errorString: "\(errorMessage)")
                    }
                }
            }
        }
    }

    func loginToFacebook(completionHandler: (success: Bool, errorString: String?) -> Void) {
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString

        let tokenCredentials = [
            "access_token" : accessToken
        ]

        let parameters: [String: AnyObject] = [
            "facebook_mobile" : tokenCredentials
        ]

        UdacityClient.sharedInstance().taskForPOSTMethod(UdacityClient.Methods.POSTASession, parameters: parameters) { result, error in
            if let error = error {
                completionHandler(success: false, errorString: "\(error)")
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    if let account = result["account"] as? [String: AnyObject] {
                        if account["registered"] as! Bool == true {
                            println("account registered")
                            UdacityClient.Constants.UserID = account["key"] as? String
                            if let session = result["session"] as? [String: AnyObject] {
                                UdacityClient.Constants.UserSessionID = session["id"] as? String
                            }
                            completionHandler(success: true, errorString: nil)
                        }
                    } else {
                        let errorMessage = result["error"] as! String
                        completionHandler(success: false, errorString: "\(errorMessage)")
                    }
                }
            }
        }
    }

    func getUsersDetails(completionHandler: (success: Bool, errorString: String?) -> Void) {
        UdacityClient.sharedInstance().taskForGETMethod(UdacityClient.Methods.GETPublicUserData) { result, error in
            if let error = error {
                completionHandler(success: false, errorString: "\(error)")
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    if let user = result["user"] as? [String: AnyObject] {
                        UdacityClient.Constants.UserFirstName = user["nickname"] as? String
                        UdacityClient.Constants.UserLastName = user["last_name"] as? String
                        completionHandler(success: true, errorString: nil)
                    } else {
                        let errorMessage = result["error"] as! String
                        completionHandler(success: false, errorString: "\(errorMessage)")
                    }
                }
            }
        }
    }

    func logoutUdacityUser(completionHandler: (success: Bool, errorString: String?) -> Void) {
        UdacityClient.sharedInstance().taskForDELETEMethod(UdacityClient.Methods.DELETEASession) { result, error in
            if let error = error {
                completionHandler(success: false, errorString: "\(error)")
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    if let validSession = result["session"] as? [String: AnyObject] {
                        completionHandler(success: true, errorString: nil)
                    } else {
                        let errorMessage = result["error"] as! String
                        completionHandler(success: false, errorString: "\(errorMessage)")
                    }
                }
            }
        }
    }
}