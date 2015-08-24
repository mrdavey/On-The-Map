//
//  ViewController.swift
//  On The Map
//
//  Created by David Truong on 9/07/2015.
//  Copyright (c) 2015 David Truong. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var annotations = [MKPointAnnotation]()
    internal var loadedRestOfLocations: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadStudentLocations()
    }

    func reloadStudentLocations() {

        // Refresh annotations shown on screen
        if annotations.count > 0 {
            self.mapView.removeAnnotations(self.annotations)
            annotations.removeAll()
        }

        ParseClient.sharedInstance().getStudentLocations { result, errorString in
            if let result = result {
                dispatch_async(dispatch_get_main_queue()) {
                    for location in result {
                        self.annotations.append(location.annotation)
                    }
                    self.mapView.addAnnotations(self.annotations)
                }
            } else {
                Helpers.showAlertView(self, title: "Error Occured", message: "\(errorString)")
            }
        }
    }

    func loadRestOfStudentLocations() {
        ParseClient.sharedInstance().getRestOfStudentLocations { result, errorString in
            if let result = result {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                    for location in result {
                        self.annotations.append(location.annotation)
                    }
                    self.mapView.addAnnotations(self.annotations)
                    self.loadedRestOfLocations = true
                }
            } else {
                Helpers.showAlertView(self, title: "Error Occured", message: "\(errorString)")
            }
        }
    }

    // MARK: - MKMapViewDelegate

    // Creating 'right callout accessory view'

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        } else {
            pinView!.annotation = annotation
        }

        return pinView
    }

    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if control == view.rightCalloutAccessoryView {
            let app  = UIApplication.sharedApplication()
            app.openURL(NSURL(string: view.annotation.subtitle!)!)
        }
    }

    func mapViewDidFinishRenderingMap(mapView: MKMapView!, fullyRendered: Bool) {
        if loadedRestOfLocations == false {
            loadRestOfStudentLocations()
        }
    }
}

