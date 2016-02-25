//
//  CreateGroupViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

//protocol NewListCreatedDelegate
//{
//    func listCreated(listUID: String)
//}

class CreateGroupViewController: UIViewController, ConnectionManagerMakeListDelegate, ConnectionManagerAddMemberDelegate, ConnectionManagerAddListToUserDelegate
{

    @IBOutlet weak var listTitleTextField: UITextField!
   
    let connectionManager = ConnectionManager.sharedManager
    var currentUser: User?
    var newListUID: String?
//    var delegate: NewListCreatedDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        connectionManager.makeListDelegate = self
        connectionManager.addMemberDelegate = self
        connectionManager.addListToUserDelegate = self

    }
    
    @IBAction func onCreateButtonTapped(sender: UIButton)
    {
        if currentUser?.userLists.count > 0
        {
            for list in currentUser!.userLists
            {
                let checkList = (connectionManager.getListFor(listUID: list.listUID))!
                if checkList.name == listTitleTextField.text
                {
                    let nameAlert = UIAlertController(title: "Try Again", message: "Looks like you already have a group list with this name!", preferredStyle: UIAlertControllerStyle.Alert)
                    let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                    nameAlert.addAction(okayAction)
                    presentViewController(nameAlert, animated: true, completion: nil);
                    return
                }
            }
        }
        if listTitleTextField.text?.isEmpty == true
        {
            let alertController = UIAlertController(title: "Name Not Entered", message: "Please enter a name for your new list.", preferredStyle: .Alert)
            let okayAction = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
            alertController.addAction(okayAction)
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        

        let newList = List(name: listTitleTextField.text!)
        self.newListUID = connectionManager.createListReturnListUID(newList)
    }
    
    func connectionManagerDidMakeList()
    {
        print("list was made")
        connectionManager.addListToUser(newListUID!, toUser: currentUser!.UID)
    }
    
    func connectionManagerDidFailToMakeList()
    {
        print("list failed")
    }
    
    func connectionManagerDidAddListToUser()
    {
        print("added list to user")
        connectionManager.addMember(currentUser!.UID, toList: newListUID!)
    }
    
    func connectionManagerDidFailToAddListToUser()
    {
        print("failed to add list to user")
    }
    
    func connectionManagerDidAddMember()
    {
        print("added member to list")
//        delegate?.listCreated(newListUID!)
        performSegueWithIdentifier("NewListCreated", sender: nil)
    }
    
    func connectionManagerDidFailToAddMember()
    {
        print("failed to add member")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "NewListCreated"
        {
            let dvc = segue.destinationViewController as! ListViewController
            dvc.currentListUID = newListUID!
        }
    }

    
}
