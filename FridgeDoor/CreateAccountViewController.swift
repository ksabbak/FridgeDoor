//
//  CreateAccountViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController, ConnectionManagerCreateUserDelegate, ConnectionManagerLogInUserDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var emailTextField:    UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingView: UIView!
    
    let connectionManager = ConnectionManager.sharedManager
    var avatarImageName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate    = self
        userNameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        connectionManager.createUserDelegate = self
        connectionManager.logInUserDelegate  = self
    }
    
    //MARK: - CMCreateUserDelegate Functions
    func connectionManagerDidCreateUser(user: User) {
        print("CM Create user successful")
    }
    
    func connectionManagerDidFailToCreateUser(error: NSError) {
        print("CM Failed to Create User: \(error.localizedDescription)")
    }
    
    
    //MARK: - TextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //Could stop user from going to next field with invalid email
        if textField.isEqual(emailTextField) {
            
            userNameTextField.becomeFirstResponder()
            
        } else if textField.isEqual(userNameTextField) {
            
            passwordTextField.becomeFirstResponder()
            
        } else if textField.isEqual(passwordTextField) {
            
            passwordTextField.resignFirstResponder()
            onCreateAccountTapped(UIButton())
            
        }
        
        return true
    }
    
    
    //MARK: - CMLogInUserDeleage Functions
    func connectionManagerDidLogInUser()
    {
        performSegueWithIdentifier("ToTimelineSegue", sender: nil)
    }
    
    func connectionManagerDidFailToLogInUser(error: NSError)
    {
        loadingView.hidden = true
        print("CM Failed Log In: \(error.localizedDescription)")
    }
    
    //MARK: - Actions
    
    
    @IBAction func onViewTapped(sender: AnyObject)
    {
        emailTextField.resignFirstResponder()
        userNameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    //TODO: Show alert
    @IBAction func onCreateAccountTapped(sender: UIButton)
    {
        loadingView.hidden = false
        let newUser = User(username: userNameTextField.text!, email: emailTextField.text!, imageName: avatarImageName!)
       
        connectionManager.createUser(userObject: newUser, password: passwordTextField.text!)
    }
    
    @IBAction func onSelectAsMyAvatarTapped(segue: UIStoryboardSegue)
    {
        //Unwinds to CreateAccountViewController from AvatarVC
        let sourceViewController = segue.sourceViewController as! AvatarViewController
        avatarImageName = sourceViewController.avatarImageName
    }
    
    
    
    
    
}
