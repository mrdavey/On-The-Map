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

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        activityIndicator.startAnimating()
        dispatch_sync(dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)) {
            self.loadStudentLocations()
            self.loadRestOfStudentLocations()
            self.viewComesIntoView()
        }
    }

    func viewComesIntoView() {
        activityIndicator.startAnimating()
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))

        dispatch_after(delay, dispatch_get_main_queue()) {
            self.mapView.removeAnnotations(self.annotations)
            self.annotations.removeAll(keepCapacity: false)

            for location in self.appDelegate.studentLocations {
                self.annotations.append(location.annotation)
            }
            self.mapView.addAnnotations(self.annotations)
            self.activityIndicator.stopAnimating()
        }
    }

    func loadStudentLocations() {
        dispatch_async(dispatch_get_main_queue()) {
            self.appDelegate.loadStudentRecords { success, error in
                if let error = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        Helpers.showAlertView(self, title: "Error occured", message: "There was an error loading the student records. \(error.localizedDescription)")
                    }
                }
            }

            for location in self.appDelegate.studentLocations {
                self.annotations.append(location.annotation)
            }
            self.mapView.addAnnotations(self.annotations)
        }
    }

    func loadRestOfStudentLocations() {
        dispatch_async(dispatch_get_main_queue()) {
            self.appDelegate.loadRestOfStudentLocations { result, error in
                if let error = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        Helpers.showAlertView(self, title: "Error occured", message: "Could not load remaining students \(error.localizedDescription)")
                    }
                }
            }
            self.mapView.removeAnnotations(self.annotations)
            self.annotations.removeAll(keepCapacity: false)

            for location in self.appDelegate.studentLocations {
                self.annotations.append(location.annotation)
            }

            self.mapView.addAnnotations(self.annotations)
            self.appDelegate.loadedRestOfLocations = true
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

}

