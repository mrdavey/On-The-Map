//
//  OnTheMapUITabBarController.swift
//  On The Map
//
//  Created by David Truong on 19/08/2015.
//  Copyright (c) 2015 David Truong. All rights reserved.
//

import UIKit
import MapKit

class OnTheMapUITabBarController: UITabBarController, UITabBarDelegate, passBackAnnotationDelegate {

    private let mapViewIndex = 0
    private let tableViewIndex = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavControllerButtons()
    }

    func passBackAnnotation(annotation: MKPlacemark) {
        refreshButtonPressed()
        if self.selectedIndex == mapViewIndex {
            let mapView = self.selectedViewController as! MapViewController
            mapView.mapView.setCenterCoordinate(annotation.location.coordinate, animated: true)
        } else if self.selectedIndex == tableViewIndex {
            // Do nothing, for now.
        } else {
            println("invalid view selected")
        }
    }

    // Set up the navigationController buttons
    func setupNavControllerButtons() {
        let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("addButtonPressed"))
        var refreshButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: Selector("refreshButtonPressed"))
        let logoutButton: UIBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logoutButtonPressed")

        self.title = "On The Map"
        self.navigationItem.leftBarButtonItem = logoutButton
        self.navigationItem.rightBarButtonItems = [refreshButton, addButton]
    }

    func addButtonPressed() {
        let vc = storyboard!.instantiateViewControllerWithIdentifier("InformationPostingView") as! InformationPostingViewController
        vc.delegate = self
        presentViewController(vc, animated: true, completion: nil)
    }

    func refreshButtonPressed() {
        self.navigationItem.rightBarButtonItem!.enabled = false
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.loadedRestOfLocations = false

        if selectedIndex == mapViewIndex {
            let mapView = self.selectedViewController as! MapViewController
                mapView.loadStudentLocations()
                mapView.loadRestOfStudentLocations()
        } else if selectedIndex == tableViewIndex {
            let tableView = self.selectedViewController as! TableViewController
            tableView.loadStudentLocations()
        } else {
            println("invalid view selected")
        }
        self.navigationItem.rightBarButtonItem!.enabled = true


    }

    func logoutButtonPressed() {
        self.navigationItem.leftBarButtonItem!.enabled = false
        UdacityClient.sharedInstance().logoutUdacityUser() { success, error in
            if success {
                self.performSegueWithIdentifier("unwindSegue", sender: self)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    Helpers.showAlertView(self, title: "Error Occured", message: "Logout was not successful: \(error!.localizedDescription)")
                    self.navigationItem.leftBarButtonItem!.enabled = true
                }
            }
        }

        if let fbLogin = FBSDKAccessToken.currentAccessToken() {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        }
    }


}
