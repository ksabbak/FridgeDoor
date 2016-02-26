//
//  InviteViewController.swift
//  FridgeDoor
//
//  Created by K Sabbak on 2/25/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit
import MessageUI

class InviteViewController: UIViewController, MFMailComposeViewControllerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var listPicker: UIPickerView!
    
    let connectionManager = ConnectionManager.sharedManager
    var currentUser: User!
    //var chosenList: (String, String)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listPicker.delegate = self
        listPicker.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    @IBAction func onRegularInviteTapped(sender: AnyObject)
    {
        
        if userTextField.text != nil && userTextField.text!.containsString("@") && userTextField.text!.containsString(".")
        {
            let userInvite = (userTextField.text?.stringByReplacingOccurrencesOfString(" ", withString: ""))!
            connectionManager.checkEmailAgainstExistingUsers(userInvite, completion: { (success) -> Void in
                
                print("1")
                if success.characters.count > 0
                {
                    print("2")
                    print("\(self.getPickerRowAsTuple().1)")
                    self.connectionManager.setPendingRequest(self.currentUser.UID, toUID: success, forList: self.getPickerRowAsTuple().1)
                    return
                }
                else
                {
                    print("3")
                    self.noExistingUserAlert()
                }
            })
        }
        else
        {
            badEmailAlert()
        }

        
    }
 
    //MARK: - Email stuff
    
    @IBAction func onEmailInviteTapped(sender: AnyObject)
    {
        
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        else
        {
            if userTextField.text != nil && userTextField.text!.containsString("@") && userTextField.text!.containsString(".")
            {
                let userInvite = (userTextField.text?.stringByReplacingOccurrencesOfString(" ", withString: ""))!
                makeEmail(userInvite)
                connectionManager.setPendingRequest(self.currentUser.UID, toEmail: userTextField.text!, forList: self.getPickerRowAsTuple().1)
            }
            else
            {
                badEmailAlert()
            }
        }
    }
    
    
    func makeEmail(toInvited: String)
    {
        let emailVC = MFMailComposeViewController()
        emailVC.mailComposeDelegate = self
        
        
        emailVC.setToRecipients([toInvited])
        emailVC.setSubject("FridgeDoor invite!")
        
        //TODO: Edit list name when we have a list here.
        //print("ChosenList.0: \(chosenList.0)")
        emailVC.setMessageBody("Hello! \n\nI would like to invite you to my shopping list \"\(getPickerRowAsTuple().0)\" on the app FridgeDoor. Just open the app and accept my invitation. If you don't have the app yet, download it and sign up with this email to get started with the list I want you to join!", isHTML: false)
        
        // Present the view controller modally.
        self.presentViewController(emailVC, animated: true, completion: nil)

    }
    
    
    ///To be displayed when an invalid email address gets typed.
    func badEmailAlert()
    {
        let badText = UIAlertController(title: "Try Again", message: "Please enter a valid email address", preferredStyle: UIAlertControllerStyle.Alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: .Default ) { (UIAlertAction) -> Void in
        }
        
        badText.addAction(okayAction)
        
        presentViewController(badText, animated: true, completion: nil);
    }
    
    
    //To be displayed when there is no associated user with the email provided
    func noExistingUserAlert()
    {
        let noUser = UIAlertController(title: "Oops!", message: "Looks like that email isn't associated with an existing account. Please use the email invite instead!", preferredStyle: UIAlertControllerStyle.Alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: .Default ) { (UIAlertAction) -> Void in
        }
        
        noUser.addAction(okayAction)
        
        presentViewController(noUser, animated: true, completion: nil);
    }

    
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?)
    {
        if error != nil
        {
            print("Email error: \(error)")
        }
        else
        {
            print("Email result: \(result)")
        }
        
        if result == MFMailComposeResultSent
        {
           // connectionManager.setPendingRequest(self.currentUser.UID, toEmail: userTextField.text!, forList: self.chosenList.1)
            print(result)
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Textfield delegate stuff
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        return textField.resignFirstResponder()
    }
    
    //MARK: - Picker delegate stuff
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentUser.userLists.count
    }
    
    //Number of columns
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
            return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let listTitle = (connectionManager.getListFor(listUID: currentUser.userLists[row].listUID)?.name)!
        
        return listTitle
    }
    
    func getPickerRowAsTuple() -> (String, String)
    {
        let row = listPicker.selectedRowInComponent(0)
        
        let title = connectionManager.getListFor(listUID: currentUser.userLists[row].listUID)?.name
        
        let tupleList = (title!, currentUser.userLists[row].listUID)
        return tupleList
    }
    
//    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        
//        let title = connectionManager.getListFor(listUID: currentUser.userLists[row].listUID)?.name
//        chosenList = (title!, currentUser.userLists[row].listUID)
//    }
}
