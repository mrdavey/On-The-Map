//
//  InformationPostingViewController.swift
//  On The Map
//
//  Created by David Truong on 8/08/2015.
//  Copyright (c) 2015 David Truong. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var findOnTheMapButton: UIButton! {
        didSet {
            findOnTheMapButton.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var titleTextView: UIView!
    @IBOutlet weak var enterURLTextField: UITextField!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton! {
        didSet {
            submitButton.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    var bottomConstraintDefaultValue: CGFloat!
    var locationAnnotation: MKPlacemark?
    var delegate: passBackAnnotationDelegate?
    var onMapView: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.locationTextField.delegate = self
        enterURLTextField.hidden = true
        mapView.hidden = true
        submitButton.hidden = true
        locationTextField.becomeFirstResponder()

        // Set up for moving action button above keyboard when shown
        bottomConstraintDefaultValue = bottomConstraint.constant
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }

    @IBAction func findOnMapButtonPressed(sender: UIButton) {
        self.view.endEditing(true)
        showMapView(true)
        geocodeAddress(locationTextField.text) { success in
            if success {
                self.enterURLTextField.becomeFirstResponder()
            }
        }
    }

    @IBAction func submitLocationButtonPressed(sender: AnyObject) {
        // Must have URL associated with pin
        if verifyURL(self.enterURLTextField.text) {
            // Set up JSON
            let jsonBody: [String : AnyObject] = [
                "uniqueKey" : UdacityClient.Constants.UserID!,
                "firstName" : UdacityClient.Constants.UserFirstName!,
                "lastName" : UdacityClient.Constants.UserLastName!,
                "mapString" : locationAnnotation!.title,
                "mediaURL" : enterURLTextField.text,
                "latitude" : Float(locationAnnotation!.location.coordinate.latitude),
                "longitude" : Float(locationAnnotation!.location.coordinate.longitude),
            ]

            // Check if location already exists
            ParseClient.sharedInstance().queryStudentLocation() { result, error in
                if result {
                    println("Duplicate found, updating")
                    ParseClient.sharedInstance().updateStudentLocation(ParseClient.Constants.StudentLocationObjectId, parameters: jsonBody) { success, error in
                        if success {
                            println("updated!")
                            self.passDataBackToParentVC()
                        } else {
                            Helpers.showAlertView(self, title: "Error Occured", message: "There was an error updating the location: \(error)")
                        }
                    }
                } else if result == false && error == nil {
                    println("No duplicate found, creating new location")
                    ParseClient.sharedInstance().createStudentLocation(jsonBody) { success, error in
                        if success {
                            self.passDataBackToParentVC()
                        } else {
                            Helpers.showAlertView(self, title: "Error Occured", message: "Could not create location point on map: \(error)")
                        }
                    }

                } else {
                    Helpers.showAlertView(self, title: "Error Occured", message: "An error occured:  \(error)")
                }
            }
        } else {
            Helpers.showAlertView(self, title: "Invalid URL entered", message: "Please enter a valid URL (including the 'http'). ")
        }
    }

    func passDataBackToParentVC() {
        delegate!.passBackAnnotation(locationAnnotation!)
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func cancelButton(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK:- Helpers

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        self.bottomConstraint.constant = keyboardFrame.size.height

        UIView.animateWithDuration(2.0) {
            self.view.layoutIfNeeded()
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        self.bottomConstraint.constant = bottomConstraintDefaultValue
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if self.onMapView == false {
            showMapView(true)
            geocodeAddress(locationTextField.text) { success in
                if success {
                    self.enterURLTextField.delegate = self
                    self.onMapView = true
                }
            }
        } else {
            self.submitLocationButtonPressed(self)
        }

        return true
    }

    // Show mapView + associated assets
    func showMapView(status: Bool) {
        var hideMapViewElements: Bool
        var hideNonMapViewElements: Bool
        var topBarViewBGColor: UIColor

        if status == true {
            hideMapViewElements = false
            hideNonMapViewElements = true
            topBarViewBGColor = UIColor(red: 0.451, green: 0.716, blue: 0.917, alpha: 1)
            enterURLTextField.becomeFirstResponder()
        } else {
            hideMapViewElements = true
            hideNonMapViewElements = false
            topBarViewBGColor = UIColor(red: 0.874, green: 0.874, blue: 0.874, alpha: 1)
        }

        // Map related elements
        enterURLTextField.hidden = hideMapViewElements
        mapView.hidden = hideMapViewElements
        submitButton.hidden = hideMapViewElements
        topBarView.backgroundColor = topBarViewBGColor

        // Non-map related elements
        findOnTheMapButton.hidden = hideNonMapViewElements
        titleTextView.hidden = hideNonMapViewElements
    }

    func geocodeAddress(address: String, completionHandler: (success: Bool) -> Void) {
        var geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { result, error in
            if let validAddress = result?[0] as? CLPlacemark {
                let annotation = MKPlacemark(placemark: validAddress)
                self.mapView.addAnnotation(annotation)
                self.mapView.setCenterCoordinate(validAddress.location.coordinate, animated: true)
                self.mapView.selectAnnotation(annotation, animated: true)
                self.locationAnnotation = annotation
                completionHandler(success: true)
            } else {
                Helpers.showAlertView(self, title: "Error Occured", message: "Unable to geocode the address: \(error). Please try again.")
                self.showMapView(false)
                self.locationTextField.text = ""
                completionHandler(success: false)
            }
        }
    }

    func verifyURL(urlString: String) -> Bool {
        if !enterURLTextField.text.isEmpty {
            if let url = NSURL(string: urlString) {
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        Helpers.showAlertView(self, title: "Invalid URL entered", message: "Please enter a valid URL. ")
        return false
    }

    // MARK: - For debugging purposes
    func deleteStudentLocation() {
        ParseClient.sharedInstance().deleteStudentLocation(ParseClient.Constants.StudentLocationObjectId) { success, error in
            if success {
                self.passDataBackToParentVC()
            } else {
                println("error deleting")
            }
        }
    }
}
