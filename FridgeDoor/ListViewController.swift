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


class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ConnectionManagerSetUpCurrentUserDelegate, ConnectionManagerListChangesDelegate, ConnectionManagerUserChangesDelegate, PerformSeguesForSettingsVCDelegate, ListItemTableViewCellDelegate, ProfileListSelectedDelegate, AddItemBackButtonDelegate
{

    @IBOutlet weak var tableView: UITableView!
    var menuDelegate: CenterViewControllerDelegate?
    let connectionManager = ConnectionManager.sharedManager
    var currentUser: User!
    var currentListUID = ""
    var theList: List!
    var visibleList = [Item]()
    var itemsPendingRemoval = [Item]()
    var members: [User] = []
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var mintView: UIImageView!
    @IBOutlet weak var boughtButton: UIButton!
    
    var tempArray:[String] = ["Banana", "Apple"]       //DELETE ME: This is a temporary array for testing reasons.
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        print("_____________________START OF SELF__________________ \n\(self)\n_____________________END OF SELF_______________")
        
        //This is to fix that stupid uglyass gap between the rows and the edge of the screen. 
        //TODO: figure out the right numbers.
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, -5)
        
        tableView.backgroundColor = UIColor.appVeryLightBlueColor()
        tableView.separatorColor = UIColor.appDarkBlueColor()
        
        disableBoughtButton()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        connectionManager.setupCurrentUserDelegate = self
        connectionManager.userChangedDelegate = self
        connectionManager.listChangedDelegate = self
        
        print("checkUserAuth")
        checkUserAuth()

//        tableView.reloadData()
    }
    
    
    func checkUserAuth()
    {
        
        if connectionManager.isLoggedIn()
        {
            connectionManager.setupCurrentUser()
        }
        else
        {
            performSegueWithIdentifier("LoginSegue", sender: self)
        }
    }


    //MARK: - User Setup
    
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
//            tableView.reloadData()
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
            
            setVisibleList()
        }
        
        
        
        print("OKAY BUT CAN WE JUST GET ALONG?")
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
        tableView.reloadData()
    }

    
    //MARK: - Buttons
    
    @IBAction func onBoughtButtonTapped(sender: UIButton)
    {
        var count = 1                       //To keep track of where we are in the for loop.
        for item in itemsPendingRemoval
        {
         connectionManager.makeInctive(item.UID, onList: theList.UID, completion: { () -> Void in
            if count == self.itemsPendingRemoval.count      //Tableview shouldn't reload until all items are inactive
            {
                print("item removed: \(item)")
                self.tableView.reloadData()
            }
            
            if item.rotating == "true"
            {
                self.connectionManager.rotate(item, onList: self.theList.UID)
            }
         })
            count++
            connectionManager.addHistoryItem(item, toList: theList.UID, purchasedBy: currentUser.UID)
        }
        
        itemsPendingRemoval = []
    }
    
    
    @IBAction func onSettingsButtonTapped(sender: UIBarButtonItem)
    {
        menuDelegate?.toggleLeftPanel?()
        print("menu delegate: \(menuDelegate)")
    }

    func enableBoughtButton()
    {
//        boughtButton.backgroundColor = UIColor.appWineColor()
//        boughtButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        boughtButton.enabled = true
        UIView.animateWithDuration(0.2) { () -> Void in
            self.boughtButton.alpha = 1.0
        }
    }
    
    func disableBoughtButton()
    {
        boughtButton.enabled = false
        UIView.animateWithDuration(0.2) { () -> Void in
            self.boughtButton.alpha = 0
        }
    }

    //MARK: - Housekeeping
    
    ///Pulls active items from backend list
    func setVisibleList()
    {
        visibleList = []
        for item in theList.items
        {
            if item.active != ""
            {
                visibleList.append(item)
            }
        }
    }
    
    ///Removes an item from the pendingRemoval array without changing its Active status.
    func removeItemFromPendingRemoval(item: Item)
    {
        for i in 0 ..< itemsPendingRemoval.count
        {
            if itemsPendingRemoval[i] == item
            {
                itemsPendingRemoval.removeAtIndex(i)
                break
            }
        }

    }
    
    
    func deleteOrRemoveAlert(item: Item)
    {
        let deletionAlert = UIAlertController(title: "Are you sure?", message: "Do you want to permanently remove the item and all its data or remove it from the active shopping list but leave it available for later?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let deleteAction = UIAlertAction(title: "DELETE Item", style: .Destructive ) { (UIAlertAction) -> Void in
            self.connectionManager.deleteItem(item.UID, fromList: self.theList.UID, withClosure: { () -> Void in
                self.removeItemFromPendingRemoval(item)
                print("Item successfully deleted from existence")
            })
        }
        
        let removeAction = UIAlertAction(title: "Remove Item", style: .Default ) { (UIAlertAction) -> Void in
            self.connectionManager.makeInctive(item.UID, onList: self.theList.UID, completion: { () -> Void in
                self.removeItemFromPendingRemoval(item)
                print("Item successfully removed from list")
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel ) { (UIAlertAction) -> Void in
        }
        
        deletionAlert.addAction(removeAction)
        deletionAlert.addAction(deleteAction)
        deletionAlert.addAction(cancelAction)
        
        presentViewController(deletionAlert, animated: true, completion: nil);
 
    }
    
    
    //MARK: - Tableview delegate stuff
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID")! as! ListItemTableViewCell
        cell.delegate = self
        
        if visibleList.count > 0
        {
            let item = visibleList[indexPath.row]
            
            cell.nameLabel.text = item.name
            
            if item.highAlert.characters.count > 0
            {
                cell.topIcon.hidden = false
            }
            else
            {
                cell.topIcon.hidden = true
            }
            
            if item.comments.count > 0
            {
                cell.bottomIcon.hidden = false
                cell.numberOfComments.hidden = false
                cell.numberOfComments.text = "\(item.comments.count)"
            }
            else
            {
                cell.bottomIcon.hidden = true
                cell.numberOfComments.hidden = true
            }
            
            if itemsPendingRemoval.contains(item)
            {
                cell.checkboxButton.setImage(UIImage(named: "check"), forState: .Normal)
            }
            else
            {
                cell.checkboxButton.setImage(UIImage(named: "box"), forState: .Normal)
            }
            
            if item.rotating == "true"
            {
               print("rotating is true")
                cell.volunteerAvatar.hidden = false
                cell.usernameLabel.hidden = false
                var userTurnUID = String()
                for userTurn in item.rotate
                {
                    if userTurn.turn == "1"
                    {
                        print("found userTurnUID: \(userTurn.userTurnUID)")
                        userTurnUID = userTurn.userTurnUID
                    }
                }
                connectionManager.getUserFor(userTurnUID, completion: { (user: User) -> Void in
                    print("in rotating closure")
                    cell.volunteerAvatar.image = UIImage(named: "\(user.imageName)")
                    cell.usernameLabel.text = user.username
                })
            }
            else if item.volunteerUID.characters.count > 0
            {
                print("there is a volunteer for this item")
                cell.volunteerAvatar.hidden = false
                connectionManager.getUserFor(item.volunteerUID, completion: { (user: User) -> Void in
                    print("volunteer closure")
                    cell.volunteerAvatar.image = UIImage(named: "\(user.imageName)")
                    cell.usernameLabel.text = user.username
                })
            }
            else
            {
                cell.volunteerAvatar.hidden = true
                cell.usernameLabel.hidden = true
            }
        }
        
        return cell
    }
    
    //For making sure all data passed between the lists is visible immediately
    func backButtonDataReload()
    {
        theList = connectionManager.getListFor(listUID: theList.UID)
        setVisibleList()
        print("The delegate was called. Horray.")
        tableView.reloadData()
    }
    
    
    //When tapping the check box on the list, the items will be checked but not "bought" until boughtButton is tapped
    //This method adds or removes these items from a pendingRemoval array.
    //NOTE: This may need tweeks in the long run if we want to change app structure. The data does not persist.
    func didTapButton(cell: ListItemTableViewCell)
    {
        let rowItem = visibleList[(tableView.indexPathForCell(cell)?.row)!]
        print("taptaptap")
        print(itemsPendingRemoval)
        
        if !itemsPendingRemoval.contains(rowItem)
        {
            cell.checkboxButton.setImage(UIImage(named: "check"), forState: .Normal)
            itemsPendingRemoval.append(rowItem)
        }
        else
        {
            cell.checkboxButton.setImage(UIImage(named: "box"), forState: .Normal)
            tableView.reloadData()
            
            //remove row item from itemsPendingRemoval when its box is unchecked
           removeItemFromPendingRemoval(rowItem)
        }
        
        if itemsPendingRemoval.count > 0
        {
            enableBoughtButton()
        }
        else
        {
            disableBoughtButton()
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return visibleList.count
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("DetailSegue", sender: indexPath)
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        print("Deselected")
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if (editingStyle == UITableViewCellEditingStyle.Delete)
        {
            let item = visibleList[indexPath.row]
            deleteOrRemoveAlert(item)
            tableView.reloadData()
        }
    }
    
    
    //MARK: - Prepare for segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddItemSegue"
        {
            let dvc = segue.destinationViewController as! AddItemViewController
            
            dvc.backbuttonDelegate = self
            
            dvc.list = theList
            
        }
        if segue.identifier == "NewGroupSegue"
        {
            let dvc = segue.destinationViewController as! StartOrJoinGroupViewController
            dvc.currentUser = currentUser
        
        }
        if segue.identifier == "DetailSegue"
        {
            let dvc = segue.destinationViewController as! DetailsViewController
            dvc.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
            
            dvc.item = visibleList[(sender?.row)!]
            dvc.list = theList
            dvc.currentUser = currentUser
        }
        
        if segue.identifier == "Profile"
        {
            let dvc = segue.destinationViewController as! ProfileViewController
            dvc.passedUser = currentUser
        }
        if segue.identifier == "Create New List"
        {
            let dvc = segue.destinationViewController as! CreateGroupViewController
            dvc.currentUser = currentUser
        }
        if segue.identifier == "Add Member"
        {
            let dvc = segue.destinationViewController as! InviteViewController
            dvc.currentUser = currentUser
        }
        if segue.identifier == "Pending"
        {
            let dvc = segue.destinationViewController as! JoinTableViewController
            dvc.currentUser = currentUser
        }
        
        if segue.identifier == "View History"
        {
            let dvc = segue.destinationViewController as! HistoryTableViewController
            dvc.listHistory = theList.historyItems
        }
        
    }
    
    
    //MARK: - Additional delegate stuff
    
    func connectionManagerDidLogOut()
    {
        checkUserAuth()
    }

    func settingTapped(setting: String)
    {
        performSegueWithIdentifier(setting, sender: nil)
        print("something worked")
        
        menuDelegate!.toggleLeftPanel!()
    }

    //Mark: Unwind from ProfileVC and ProfileVC Delegate
    
    @IBAction func listSelectedFromProfile(segue: UIStoryboardSegue)
    {
        //Unwinds to ListVC from ProfileVC
        let sourceVC = segue.sourceViewController as! ProfileViewController
        sourceVC.delegate = self
        print("Profile delegate was fired")
    }
    
    func listSelected(listUID: String)
    {
        currentListUID = listUID
        theList = connectionManager.getListFor(listUID: currentListUID)
        tableView.reloadData()
    }
    
    
    @IBAction func unwindToListVC(segue: UIStoryboardSegue)
    {
        //Unwinds from a lot of places
        //1. On Logout
        //2. from CreateAccount
        //3. From CreateGroup
        //4. From JoinGroup.
        //5. ? Maybe, probably.
    }
    
    

}
