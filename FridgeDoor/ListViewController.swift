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

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ConnectionManagerSetUpCurrentUserDelegate, ConnectionManagerLogOutDelegate, ConnectionManagerListChangesDelegate, ConnectionManagerUserChangesDelegate, ListItemTableViewCellDelegate
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
        
        //This is to fix that stupid uglyass gap between the rows and the edge of the screen. 
        //TODO: figure out the right numbers.
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
        tableView.reloadData()
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
            connectionManager.setupListObservers(currentUser)
            mintView.hidden = true
            print(currentUser.username)
            print(currentUser.userLists)
            tableView.reloadData()
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
            connectionManager.setupMemberObservers(theList)
        }
        
        tableView.reloadData()
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
    
    
    //MARK: - Tableview delegate stuff
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID")! as! ListItemTableViewCell
        cell.delegate = self
        
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
        
        return cell
    }
    
    func didTapButton(cell: ListItemTableViewCell)
    {
        print("I'm not sure I needed this now that I'm half way through writing it.")
        
        //let selectedCell = tableView.cellForRowAtIndexPath() as ListItemTableViewCell
        
        if cell.checkboxButton.imageView?.image == UIImage(named: "box")
        {
            cell.checkboxButton.setImage(UIImage(named: "check"), forState: .Normal)
        }
        else
        {
            cell.checkboxButton.setImage(UIImage(named: "box"), forState: .Normal)
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if theList != nil
        {
            print("this happened")
            return theList.items.count
        }

        return 0
    }

    
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
