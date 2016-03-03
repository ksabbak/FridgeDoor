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

class CreateGroupViewController: UIViewController, ConnectionManagerMakeListDelegate, ConnectionManagerAddMemberDelegate, ConnectionManagerAddListToUserDelegate, UITextFieldDelegate
{

    @IBOutlet weak var listTitleTextField: UITextField!
   
    let connectionManager = ConnectionManager.sharedManager
    var currentUser: User?
    var newListUID: String?
    var newList: List?
    var leepFrog: Bool?
//    var delegate: NewListCreatedDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        connectionManager.makeListDelegate = self
        connectionManager.addMemberDelegate = self
        connectionManager.addListToUserDelegate = self
        view.backgroundColor = UIColor.appVeryLightBlueColor()
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = UIImage(named: "FridgeDoorLogoSmall")
        navigationItem.titleView = imageView

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
        

        let temporaryList = List(name: listTitleTextField.text!)
        self.newListUID = connectionManager.createListReturnListUID(temporaryList)
    }
    
    func connectionManagerDidMakeList(list: List)
    {
        print("list was made")
        self.newList = list
        connectionManager.addListToUser(newListUID!, toUser: currentUser!.UID)
    }
    
    func connectionManagerDidFailToMakeList()
    {
        print("list failed")
    }
    
    func connectionManagerDidAddListToUser()
    {
        print("added list to user")
        connectionManager.addMember(currentUser!.UID, toList: newList!)
    }
    
    func connectionManagerDidFailToAddListToUser()
    {
        print("failed to add list to user")
    }
    
    func connectionManagerDidAddMember()
    {
        print("added member to list")
//        delegate?.listCreated(newListUID!)
        
        if leepFrog == true
        {
            performSegueWithIdentifier("LeepFrogSegue", sender: nil)
        }
        else
        {
            performSegueWithIdentifier("NewListCreated", sender: nil)
        }
    }
    
    func connectionManagerDidFailToAddMember()
    {
        print("failed to add member")
    }
    
    
    //MARK: - Textfield delegate stuff
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        return textField.resignFirstResponder()
    }
    
    
    //MARK: - Prepare for segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "NewListCreated"
        {
            let dvc = segue.destinationViewController as! ListViewController
            dvc.currentListUID = newListUID!
        }
    }

    @IBAction func onScreenTapped(sender: UITapGestureRecognizer)
    {
        listTitleTextField.resignFirstResponder()
    }
    
}
