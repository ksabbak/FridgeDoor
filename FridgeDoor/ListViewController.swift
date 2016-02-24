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


class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ConnectionManagerSetUpCurrentUserDelegate, ConnectionManagerLogOutDelegate, ConnectionManagerListChangesDelegate, ConnectionManagerUserChangesDelegate, PerformSeguesForSettingsVCDelegate, ListItemTableViewCellDelegate
{

    @IBOutlet weak var tableView: UITableView!
    var menuDelegate: CenterViewControllerDelegate?
    let connectionManager = ConnectionManager.sharedManager
    var currentUser: User!
    var currentListUID = ""
    var theList: List!
    var members: [User] = []
    
    //var passedItem: Item!
    
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
            
            if item.active == ""
            {
                cell.checkboxButton.setImage(UIImage(named: "check"), forState: .Normal)
            }
            else
            {
                cell.checkboxButton.setImage(UIImage(named: "box"), forState: .Normal)
            }
        }
        }
        
        return cell
    }
    
    func didTapButton(cell: ListItemTableViewCell)
    {
        let rowItem = theList.items[(tableView.indexPathForCell(cell)?.row)!]
        
        if rowItem.active != ""
        {
            cell.checkboxButton.setImage(UIImage(named: "check"), forState: .Normal)
            connectionManager.makeInactive(rowItem.UID, fromList: theList.UID)

        }
        else
        {
            cell.checkboxButton.setImage(UIImage(named: "box"), forState: .Normal)
            connectionManager.makeActive(rowItem.UID, onList: theList.UID)

        }
        tableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if theList != nil
        {
            return theList.items.count
        }

        return 0
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        cell.preservesSuperviewLayoutMargins = false
//        cell.layoutMargins = UIEdgeInsetsZero
//    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //passedItem = theList.items[indexPath.row]
        performSegueWithIdentifier("DetailSegue", sender: indexPath)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddItemSegue"
        {
            let dvc = segue.destinationViewController as! AddItemViewController
            
            dvc.list = theList
            
        }
        else if segue.identifier == "NewGroupSegue"
        {
            let dvc = segue.destinationViewController as! StartOrJoinGroupViewController
            dvc.currentUser = currentUser
        
        }
        else if segue.identifier == "DetailSegue"
        {
            let dvc = segue.destinationViewController as! DetailsViewController
            dvc.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
            
            dvc.item = theList.items[(sender?.row)!]
        }
        
        if segue.identifier == "Profile"
        {
            let dvc = segue.destinationViewController as! ProfileViewController
            dvc.passedUser = currentUser
        }
        
    }

    func connectionManagerDidLogOut()
    {
        checkUserAuth()
    }

    func settingTapped(setting: String)
    {
        performSegueWithIdentifier(setting, sender: nil)
    }

}
