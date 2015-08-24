//
//  TableViewController.swift
//  On The Map
//
//  Created by David Truong on 7/08/2015.
//  Copyright (c) 2015 David Truong. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UITableViewDelegate {

    var studentLocations = [StudentLocations]()
    internal var reloadedRestOfData: Bool = false
    var indicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        addActivityLoadingIndicator()
        loadStudentLocations()

    }

    func loadStudentLocations() {
        tableView.separatorStyle = .None
        indicator.startAnimating()
        if studentLocations.count > 0 {
            studentLocations.removeAll()
        }
        
        ParseClient.sharedInstance().getStudentLocations { result, errorString in
            if let result = result {
                dispatch_async(dispatch_get_main_queue()) {
                    for student in result {
                        self.studentLocations.append(student)
                    }
                    self.tableView.reloadData()
                    self.indicator.stopAnimating()
                    self.tableView.separatorStyle = .SingleLine
                }
            } else {
                println(errorString)
                // TODO: pop up error box
            }
        }
    }

    func loadRestOfStudentLocations() {
        self.indicator.startAnimating()
        ParseClient.sharedInstance().getRestOfStudentLocations { result, errorString in
            if let result = result {
                dispatch_async(dispatch_get_main_queue()) {
                    for student in result {
                        self.studentLocations.append(student)
                    }
                    self.reloadedRestOfData = true
                    self.tableView.reloadData()
                    self.indicator.stopAnimating()
                }
            } else {
                println(errorString)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentLocations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        let studentLocation = studentLocations[indexPath.row]

        cell.textLabel?.text = studentLocation.annotation.title
        // TODO: - Add cell map image

        return cell
    }

    // MARK: - TableView Delgate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Open URL when cell clicked
        let mediaURL = studentLocations[indexPath.row].annotation.subtitle
        let app  = UIApplication.sharedApplication()
        app.openURL(NSURL(string: mediaURL)!)
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if reloadedRestOfData == false {
            if indexPath.row == studentLocations.count - 1 {
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
