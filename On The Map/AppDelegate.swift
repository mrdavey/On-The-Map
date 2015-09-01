//
//  AppDelegate.swift
//  On The Map
//
//  Created by David Truong on 9/07/2015.
//  Copyright (c) 2015 David Truong. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var studentLocations = [StudentLocations]()
    var loadedRestOfLocations: Bool = false

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch. 

        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func loadStudentRecords(completionHandler: (success: Bool, error: NSError?) -> Void) {
        self.studentLocations.removeAll(keepCapacity: false)

        ParseClient.sharedInstance().getStudentLocations { result, errorString in
            if let result = result {
                dispatch_async(dispatch_get_main_queue()) {
                    for student in result {
                        self.studentLocations.append(student)
                    }
                    completionHandler(success: true, error: nil)
                }
            } else {
                completionHandler(success: false, error: errorString!)
            }
        }
    }

    func loadRestOfStudentLocations(completionHandler: (success: [StudentLocations]?, error: NSError?) -> Void) {
        ParseClient.sharedInstance().getRestOfStudentLocations { result, errorString in
            dispatch_async(dispatch_get_main_queue()) {
                if let result = result {
                    for student in result {
                        self.studentLocations.append(student)
                    }
                    completionHandler(success: result, error: nil)
                } else {
                    completionHandler(success: nil, error: errorString!)
                }
            }
        }
    }


    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject?) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

