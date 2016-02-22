//
//  CreateGroupViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class CreateGroupViewController: UIViewController, ConnectionManagerMakeListDelegate {

    @IBOutlet weak var listTitleTextField: UITextField!
   
    let connectionManager = ConnectionManager.sharedManager
    var nameExists = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectionManager.makeListDelegate = self

    }

    

    @IBAction func onCreateButtonTapped(sender: UIButton)
    {
        
        let currentUser = (connectionManager.getUserFor(userUID: connectionManager.userUID()!))!
        
        
        let newList = List(name: listTitleTextField.text!)
        
        
        let newListUID = connectionManager.createListReturnListUID(newList)
        

        connectionManager.addListToUser(newListUID, toUser: connectionManager.userUID()!)
        connectionManager.addMember(currentUser.UID, toList: newListUID)
        
        for list in currentUser.userLists
        {
            let checkList = (connectionManager.getListFor(listUID: list.listUID))!
            if checkList.name == listTitleTextField.text
            {
                badNameAlert()
                nameExists = true
            }
        }
        
        
        if canPerformSegue()
        {
            performSegueWithIdentifier("CreatedGroupSegue", sender: self)
        }
    }
    
    func badNameAlert()
    {
        let nameAlert = UIAlertController(title: "Try Again", message: "Looks like you already have a group list with this name!", preferredStyle: UIAlertControllerStyle.Alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: .Default ) { (UIAlertAction) -> Void in
            self.nameExists = false
        }
        
        nameAlert.addAction(okayAction)
        
        presentViewController(nameAlert, animated: true, completion: nil);
    }
    
    func canPerformSegue() -> Bool
    {
        if nameExists == false && listTitleTextField.text?.isEmpty == false
        {
            return true
        }
        
        return false
    }

    func connectionManagerDidFailToMakeList() {
        print("list failed")
    }
    
    func connectionManagerDidMakeList() {
        print("list was made")
    }
    

}
