//
//  TableViewController.swift
//  On The Map
//
//  Created by David Truong on 7/08/2015.
//  Copyright (c) 2015 David Truong. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UITableViewDelegate {

    var indicator = UIActivityIndicatorView()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate


    override func viewDidLoad() {
        super.viewDidLoad()

        addActivityLoadingIndicator()
        loadStudentLocations()

    }

    func loadStudentLocations() {
        tableView.separatorStyle = .None
        indicator.startAnimating()

        if appDelegate.studentLocations.isEmpty {
            appDelegate.loadStudentRecords { success, error in
                if let error = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        Helpers.showAlertView(self, title: "Error occured", message: "There was an error loading the student records. \(error.localizedDescription)")
                    }
                }
            }
        }

        self.tableView.reloadData()
        self.indicator.stopAnimating()
        self.tableView.separatorStyle = .SingleLine
    }

    func loadRestOfStudentLocations() {
        if appDelegate.loadedRestOfLocations == false {
            self.indicator.startAnimating()


            appDelegate.loadRestOfStudentLocations { result, error in
                if let error = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        Helpers.showAlertView(self, title: "Error occured", message: "Could not load remaining students \(error.localizedDescription)")
                    }
                } else {
                    self.tableView.reloadData()
                    self.indicator.stopAnimating()
                    self.appDelegate.loadedRestOfLocations = true
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.studentLocations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        let studentLocation = appDelegate.studentLocations[indexPath.row]

        cell.textLabel?.text = studentLocation.annotation.title

        return cell
    }

    // MARK: - TableView Delgate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Open URL when cell clicked
        let mediaURL = appDelegate.studentLocations[indexPath.row].annotation.subtitle
        let app  = UIApplication.sharedApplication()
        app.openURL(NSURL(string: mediaURL)!)
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if appDelegate.loadedRestOfLocations == false {
            if indexPath.row == appDelegate.studentLocations.count - 1 {
                loadRestOfStudentLocations()
            }
        }
    }

    func addActivityLoadingIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        indicator.center = CGPointMake(self.view.center.x, self.view.center.y - 50)
        indicator.color = UIColor.grayColor()
        self.view.addSubview(indicator)
        indicator.hidesWhenStopped = true
    }
}
