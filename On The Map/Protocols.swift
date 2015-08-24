//
//  Protocols.swift
//  On The Map
//
//  Created by David Truong on 19/08/2015.
//  Copyright (c) 2015 David Truong. All rights reserved.
//

import Foundation
import MapKit

protocol passBackAnnotationDelegate {
    func passBackAnnotation(annotation: MKPlacemark)
}