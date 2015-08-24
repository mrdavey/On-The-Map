//
//  ParseConstants.swift
//  On The Map
//
//  Created by David Truong on 10/07/2015.
//  Copyright (c) 2015 David Truong. All rights reserved.
//

import Foundation

extension ParseClient {

    // MARK: - Constants
    struct Constants {
        static let ApplicationID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ApiKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"

        static let BaseURL: String = "https://api.parse.com/1/"

        static var StudentLocationObjectId: String = ""
    }

    // MARK - Methods
    struct Methods {
        static let GETStudentLocations = "classes/StudentLocation"
        static let POSTStudentLocations = "classes/StudentLocation"
        static let QUERYStudentLocations = "classes/StudentLocation"
        static let PUTStudentLocation: String = "classes/StudentLocation/"
    }
}