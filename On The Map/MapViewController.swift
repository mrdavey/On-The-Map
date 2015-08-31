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
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate


    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.delegate = self
        loadStudentLocations()
    }

    func loadStudentLocations() {
        self.mapView.removeAnnotations(annotations)
        self.annotations.removeAll(keepCapacity: false)

        appDelegate.loadStudentRecords { success, error in
            if let error = error {
                dispatch_async(dispatch_get_main_queue()) {
                    Helpers.showAlertView(self, title: "Error occured", message: "There was an error loading the student records. \(error.localizedDescription)")
                }
            }
        }
        for location in appDelegate.studentLocations {
            self.annotations.append(location.annotation)
        }
        self.mapView.addAnnotations(self.annotations)
    }

    func loadRestOfStudentLocations() {
        self.mapView.removeAnnotations(self.annotations)
        self.annotations.removeAll(keepCapacity: false)

        appDelegate.loadRestOfStudentLocations { result, error in
            if let error = error {
                dispatch_async(dispatch_get_main_queue()) {
                    Helpers.showAlertView(self, title: "Error occured", message: "Could not load remaining students \(error.localizedDescription)")
                }
            } else {
                for location in self.appDelegate.studentLocations {
                    self.annotations.append(location.annotation)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.addAnnotations(self.annotations)
                    self.appDelegate.loadedRestOfLocations = true
                }
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
        if appDelegate.loadedRestOfLocations == false {
            loadRestOfStudentLocations()
        }
    }
}

