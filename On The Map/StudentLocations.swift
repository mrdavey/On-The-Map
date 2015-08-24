//
//  StudentLocations.swift
//  On The Map
//
//  Created by David Truong on 10/07/2015.
//  Copyright (c) 2015 David Truong. All rights reserved.
//

import Foundation
import MapKit

struct StudentLocations {
    let annotation = MKPointAnnotation()

    init (dictionary:[String: AnyObject]) {
        let firstName = dictionary["firstName"] as! String
        let lastName = dictionary["lastName"] as! String
        let latitude = dictionary["latitude"] as! Double
        let longitude = dictionary["longitude"] as! Double
        let mediaURL = dictionary["mediaURL"] as! String

        annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(latitude), CLLocationDegrees(longitude))
        annotation.title = "\(firstName) \(lastName)"
        annotation.subtitle = mediaURL
    }

    // Helper: Given an array of dictionaries, convert them to an array of StudentLocation objects
    static func locationsFromResults(results: [[String: AnyObject]]) -> [StudentLocations] {
        var locations = [StudentLocations]()

        for result in results {
            locations.append(StudentLocations(dictionary: result))
        }

        return locations
    }
}