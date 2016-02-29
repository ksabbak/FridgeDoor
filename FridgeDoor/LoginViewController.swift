//
//  LoginViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, ConnectionManagerLogInUserDelegate, UITextFieldDelegate
{

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loadingView: UIView!
    
    let connectionManager = ConnectionManager.sharedManager
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        emailTextField.delegate    = self
        passwordTextField.delegate = self
    }

    override func viewWillAppear(animated: Bool)
    {
        connectionManager.logInUserDelegate = self
    }
    
    
    func connectionManagerDidLogInUser()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func connectionManagerDidFailToLogInUser(error: NSError)
    {
        loadingView.hidden = true
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
        alertController.addAction(cancel)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: - TextfieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if textField.isEqual(emailTextField)
        {
            passwordTextField.becomeFirstResponder()
        }
        else if textField.isEqual(passwordTextField)
        {
            onLoginButtonTapped(UIButton())
        }
        
        return true
    }
    
    
    //MARK: - Actions
    
    @IBAction func onSignInTapped(segue: UIStoryboardSegue)
    {
        //Unwinds to LoginViewController from either SignUpVC or SignUpDetailVC
    }
    
    @IBAction func onLoginButtonTapped(sender: UIButton)
    {
        if emailTextField.text == "" || passwordTextField.text == ""
        {
            let alertController = UIAlertController(title: "Error", message: "Please enter your email address and password.", preferredStyle: .Alert)
            let cancel = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
            alertController.addAction(cancel)
            presentViewController(alertController, animated: true, completion: nil)
        }
        else
        {
            loadingView.hidden = false
            connectionManager.logInUser(emailTextField.text!, password: passwordTextField.text!)
            
            passwordTextField.resignFirstResponder()
            emailTextField.resignFirstResponder()
        }
    }
    
    
    @IBAction func onScreenTapped(sender: UITapGestureRecognizer)
    {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
   
    
}
