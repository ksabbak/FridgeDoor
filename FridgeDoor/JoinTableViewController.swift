//
//  JoinTableViewController.swift
//  FridgeDoor
//
//  Created by K Sabbak on 2/26/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class JoinTableViewController: UITableViewController, ConnectionManagerUserChangesDelegate {

    var currentUser: User!
    let connectionManager = ConnectionManager.sharedManager
    var requestsArray = [[String:AnyObject]]()
    
    var dismiss: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.appVeryLightBlueColor()
        view.backgroundColor = UIColor.appVeryLightBlueColor()
        
        if dismiss == true
        {
            let tableHeader = UIView.init(frame: CGRectMake(0, 0, 0, 75))
            tableHeader.backgroundColor = UIColor.appVeryLightBlueColor()
            
            tableView.tableHeaderView = tableHeader
        }
        
        connectionManager.userChangedDelegate = self
        
        print(currentUser.pending)
        requestsArray = []
        setUpRequestArray()
    }
    
    
    func setUpRequestArray()
    {
        for request in currentUser.pending
        {
            let listID = request["forList"]
            connectionManager.getListFromAllListsFor(listID!, completion: { (list: List) -> Void in
                self.requestsArray.append(["username": request["from"]!, "list": list, "pendingUID": request["pending"]!])
                self.tableView.reloadData()
            })
        }
    }


    ///Presents an alert controller that allows the user to accept, decline or do nothing about a pending request
    func handleRequestAlert(relevantInfo: [String:AnyObject])
    {
        let list = relevantInfo["list"] as! List
        let pendingUID = relevantInfo["pendingUID"] as! String
        
        let requestAlert = UIAlertController(title: "Join List?", message: "Would you like to accept access to this list?", preferredStyle: UIAlertControllerStyle.Alert)
        
        //Adds current user to the list, the list to the current user's lists and removes the pending request
        let joinAction = UIAlertAction(title: "Join", style: .Default ) { (UIAlertAction) -> Void in
            self.connectionManager.addListToUser(list.UID, toUser: self.currentUser.UID)
            self.connectionManager.addMember(self.currentUser.UID, toList: list)
            self.connectionManager.deletePending(self.currentUser.UID, pendingUID: pendingUID)
            self.tableView.reloadData()
            if self.dismiss == true
            {
                self.performSegueWithIdentifier("NowHaveListSegue", sender: self)
            }
        }
        
        //removes the pending request
        let declineAction = UIAlertAction(title: "Decline", style: .Destructive) { (UIAlertAction) -> Void in
            self.connectionManager.deletePending(self.currentUser.UID, pendingUID: pendingUID)
            self.tableView.reloadData()
            
            if self.dismiss == true
            {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        //does nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        requestAlert.addAction(joinAction)
        requestAlert.addAction(declineAction)
        requestAlert.addAction(cancelAction)
        
        presentViewController(requestAlert, animated: true, completion: nil);
    }
    
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return requestsArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID", forIndexPath: indexPath)
        
        cell.backgroundColor = UIColor.appVeryLightBlueColor()
        
        if requestsArray.count > 0
        {
            let username = requestsArray[indexPath.row]["username"] as! String
            let list = requestsArray[indexPath.row]["list"] as! List
            
            cell.textLabel?.text = "Request from: \(username) to join list: \(list.name)"
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        handleRequestAlert(requestsArray[indexPath.row])
    }

    func connectionManagerUserWasChanged(user: User)
    {
        if user.UID == currentUser.UID
        {
            currentUser = connectionManager.getUserFor(userUID: user.UID)
            requestsArray = []
            setUpRequestArray()
            tableView.reloadData()
        }
    }
    
//    @IBAction func newUserWantsToJoin(segue: UIStoryboardSegue)
//    {
//        //Let's hope this doesn't break things.
//       print("Nope?")
//    }
    

}


