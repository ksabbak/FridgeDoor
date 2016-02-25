//
//  InviteViewController.swift
//  FridgeDoor
//
//  Created by K Sabbak on 2/25/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit
import MessageUI

class InviteViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var listPicker: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onRegularInviteTapped(sender: AnyObject) {
    }
 
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
            }
            else
            {
                let badText = UIAlertController(title: "Try Again", message: "Please enter a valid email address", preferredStyle: UIAlertControllerStyle.Alert)
                
                let okayAction = UIAlertAction(title: "Okay", style: .Default ) { (UIAlertAction) -> Void in
                }
                
                badText.addAction(okayAction)
                
                presentViewController(badText, animated: true, completion: nil);

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
        emailVC.setMessageBody("Hello! \n\nI would like to invite you to my shopping list ***(list.name)*** on the app FridgeDoor. Just open the app and accept my invitation. If you don't have the app yet, download it and sign up with this email to get started with the list I want you to join!", isHTML: false)
        
        // Present the view controller modally.
        self.presentViewController(emailVC, animated: true, completion: nil)

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
        
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
