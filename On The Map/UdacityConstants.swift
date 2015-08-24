//
//  UdacityConstants.swift
//  On The Map
//
//  Created by David Truong on 23/08/2015.
//  Copyright (c) 2015 David Truong. All rights reserved.
//

import Foundation

extension UdacityClient {

    struct Constants {
        static let BaseURL: String = "https://www.udacity.com/api/"
        static let UdacitySignupURL: String = "https://www.udacity.com/account/auth#!/signin"

        static var UserID: String?
        static var UserFirstName: String?
        static var UserLastName: String?
        static var UserSessionID: String?
    }

    struct Methods {
        static let POSTASession: String = "session"
        static let GETPublicUserData: String = "users/\(UdacityClient.Constants.UserID!)"
        static let DELETEASession: String = "session"
    }
}