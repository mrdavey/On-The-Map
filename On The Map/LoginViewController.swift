//
//  LoginViewController.swift
//  On The Map
//
//  Created by David Truong on 23/08/2015.
//  Copyright (c) 2015 David Truong. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton! {
        didSet {
            facebookLoginButton.layer.cornerRadius = 4
        }
    }
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var bottomConstraintDefaultValue: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        setObjectGradient(self.view.layer)
        setObjectGradient(facebookLoginButton.layer)
        enableLoginButton()

        facebookLoginButton.delegate = self

        // Set up for moving layout when keyboard shown
        passwordTextField.delegate = self
        bottomConstraintDefaultValue = bottomConstraint.constant
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }

    @IBAction func loginButtonPressed(sender: AnyObject) {
        loadingIndicator.hidden = false
        loadingIndicator.startAnimating()
        loginButton.enabled = false
        loginButton.setTitle("", forState: UIControlState.Disabled)
        UdacityClient.sharedInstance().loginToUdacity(emailTextField.text, password: passwordTextField.text) { success, errorString in
            if success {
                println("login successful")
                UdacityClient.sharedInstance().getUsersDetails() { success, error in
                    if let error = error {
                        Helpers.showAlertView(self, title: "Error Occured", message: "\(error)")
                        self.enableLoginButton()
                    } else {
                        self.performSegueWithIdentifier("loginSuccessful", sender: self)
                    }
                }
            } else {
                Helpers.showAlertView(self, title: "Login Error", message: "\(errorString!) Please try again.")
                self.enableLoginButton()
            }
        }
    }

    func enableLoginButton() {
        loadingIndicator.stopAnimating()
        loadingIndicator.hidden = true
        loginButton.enabled = true
        loginButton.setTitle("Login", forState: UIControlState.Normal)
    }

    @IBAction func signupButtonPressed(sender: UIButton) {
        if let url = NSURL(string: UdacityClient.Constants.UdacitySignupURL) {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    // MARK: - Facebook Login

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if let error = error {
            Helpers.showAlertView(self, title: "Unable to Login", message: "\(error)")
        }
        else if result.isCancelled {
            Helpers.showAlertView(self, title: "Unable to Login", message: "It looks like the request was cancelled. Please try again.")
        } else {
            UdacityClient.sharedInstance().loginToFacebook() { success, errorString in
                if success {
                    UdacityClient.sharedInstance().getUsersDetails() { success, error in
                        if let error = error {
                            Helpers.showAlertView(self, title: "Error Occured", message: "\(error)")
                        } else {
                            self.performSegueWithIdentifier("loginSuccessful", sender: self)
                        }
                    }
                } else {
                    println("error: \(errorString)")
                    Helpers.showAlertView(self, title: "Error Occured", message: "\(errorString)")
                }
            }
        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    }

    // MARK: - Helpers
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()

        self.bottomConstraint.constant = keyboardFrame.size.height / 2

        UIView.animateWithDuration(2.0) {
            self.view.layoutIfNeeded()
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        self.bottomConstraint.constant = bottomConstraintDefaultValue
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.loginButtonPressed(self)
        
        return true
    }

    override func viewWillLayoutSubviews() {
        // Fix for gradientView bug on device rotation
        if self.view.layer.sublayers != nil {
            self.view.layer.sublayers.removeLast()
            setObjectGradient(self.view.layer)
        }

        if facebookLoginButton.layer.sublayers != nil {
            facebookLoginButton.layer.sublayers.removeLast()
            setObjectGradient(facebookLoginButton.layer)
        }

    }

    func setObjectGradient(layer: CALayer) {
        let gradient = CAGradientLayer()
        gradient.frame = layer.bounds

        let lighterColor = UIColor(white: 1.0, alpha: 0.4).CGColor as CGColorRef
        let transparentColor = UIColor.clearColor().CGColor as CGColorRef

        gradient.colors = [lighterColor, transparentColor]
        gradient.locations = [0.0, 1.0]

        layer.addSublayer(gradient)
        layer.masksToBounds = true
    }

    @IBAction func unwindToContainerVC(segue: UIStoryboardSegue) {
        self.enableLoginButton()
        emailTextField.text = ""
        passwordTextField.text = ""
    }

}
