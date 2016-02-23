//
//  ListViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

@objc
protocol CenterViewControllerDelegate
{
    optional func toggleLeftPanel()
    optional func toggleRightPanel()
    optional func collapseSidePanels()
}

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ConnectionManagerSetUpCurrentUserDelegate, ConnectionManagerLogOutDelegate, ConnectionManagerListChangesDelegate, ConnectionManagerUserChangesDelegate
{

    @IBOutlet weak var tableView: UITableView!
    var menuDelegate: CenterViewControllerDelegate?
    let connectionManager = ConnectionManager.sharedManager
    var currentUser: User!
    var currentListUID = ""
    var theList: List!
    var members: [User] = []
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var mintView: UIImageView!
    
    var tempArray:[String] = ["Banana", "Apple"]       //DELETE ME: This is a temporary array for testing reasons.
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, -5)
        connectionManager.setupCurrentUserDelegate = self
        connectionManager.userChangedDelegate = self
        connectionManager.listChangedDelegate = self

    }
    
    override func viewWillAppear(animated: Bool)
    {
        connectionManager.logoutDelegate = self
        print("checkUserAuth")
        checkUserAuth()
    }
    
    func connectionManagerDidSetUpCurrentUser(currentUser: User)
    {
        print("Setup current user")
        self.currentUser = currentUser
        if currentUser.userLists.count == 0
        {
            performSegueWithIdentifier("NewGroupSegue", sender: self)
        }
        else
        {
            connectionManager.setupListObservers()
            mintView.hidden = true
            print(currentUser.username)
            print(currentUser.userLists)
//            configureWithList()
        }
    }
    
    func connectionmanagerDidFailToSetUpCurrentUser()
    {
        print("Failed to setup current user")
    }
    
    func connectionManagerListWasChanged(list: List)
    {
        if currentListUID.characters.count == 0
        {
            currentListUID = currentUser.userLists[0].listUID
        }
        if currentListUID == list.UID
        {
            theList = list
            connectionManager.setupMemberObservers()
        }
    }
    
    func connectionManagerUserWasChanged(user: User)
    {
        if let foundIndex = self.members.indexOf({ $0.UID == user.UID }) {
            self.members.removeAtIndex(foundIndex)
            self.members.insert(user, atIndex: foundIndex)
        }
        else
        {
            self.members.append(user)
        }

    }
    
    func connectionManagerDidGetUserAndUpdateLists(user: User)
    {
        print("updated current user")
       
    }
    
    func connectionManagerDidFailToGetUserAndUpdateLists()
    {
        print("failed to update current user")
    }
    
    func connectionManagerDidGetListAndUpdateUsers(list: List)
    {
        print("updated current list")
        
    }
    
    func connectionManagerDidFailToGetListAndUpdateUsers()
    {
        print("failed to update current list")
    }
    
    
    
    func configureWithList()
    {
        if currentListUID.characters.count == 0
        {
            currentListUID = currentUser.userLists[0].listUID
        }
        theList = connectionManager.getListFor(listUID: currentListUID)
    }


    @IBAction func onSettingsButtonTapped(sender: UIBarButtonItem)
    {
    menuDelegate?.toggleLeftPanel?()
    }

    func checkUserAuth() {
        if connectionManager.isLoggedIn()
        {
            connectionManager.setupCurrentUser()
        }
        else
        {
            performSegueWithIdentifier("LoginSegue", sender: self)
        }
    }
    
    //MARK: - Connection Manager Logout Delegate
    
    func connectionManagerDidLogOut()
    {
        checkUserAuth()
    }

    
//    @IBAction func onAddButtonTapped(sender: UIBarButtonItem)
//    {
//        let addAlert = UIAlertController(title: "Add Item", message: "Add item below or select from your history", preferredStyle: UIAlertControllerStyle.Alert)
//        
//        addAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
//            textField.placeholder = "Item name"
//        }
//        
//        let okayAction = UIAlertAction(title: "Okay", style: .Default ) { (UIAlertAction) -> Void in
//            self.tempArray.append((addAlert.textFields?.first?.text)!)
//            self.tableView.reloadData()
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (UIAlertAction) -> Void in
//        }
//        
//        addAlert.addAction(okayAction)
//        addAlert.addAction(cancelAction)
//        
//        
//        presentViewController(addAlert, animated: true, completion: nil);
//    }
    
    
    
    
    //MARK: - Tableview delegate stuff
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID")! as! ListItemTableViewCell
        
        if theList != nil
        {
        if theList.items.count > 0
        {
            let item = theList.items[indexPath.row]
            
            cell.nameLabel.text = item.name
            
            if item.essential.characters.count > 0
            {
                cell.bottomIcon.hidden = false
            }
            else
            {
                cell.bottomIcon.hidden = true
            }
            
            if item.comments.count > 0
            {
                cell.topIcon.hidden = false
            }
            else
            {
                cell.topIcon.hidden = true
            }
        }
        }
        
        //cell.nameLabel.text = tempArray[indexPath.row]
        
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if theList != nil
        {
            print("this happened")
            return theList.items.count
        }
        //return tempArray.count
        return 0
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        cell.preservesSuperviewLayoutMargins = false
//        cell.layoutMargins = UIEdgeInsetsZero
//    }
    
    @IBAction func onLogOutTapped(sender: UIButton)
    {
        connectionManager.logout()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddItemSegue"
        {
            let dvc = segue.destinationViewController as! AddItemViewController
            
            dvc.list = theList
            
        }
        if segue.identifier == "NewGroupSegue"
        {
            let dvc = segue.destinationViewController as! StartOrJoinGroupViewController
            dvc.currentUser = currentUser
            
        }
    }

}
