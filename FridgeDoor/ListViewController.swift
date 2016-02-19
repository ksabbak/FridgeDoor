//
//  ListViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

@objc
protocol CenterViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func toggleRightPanel()
    optional func collapseSidePanels()
}

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var menuDelegate: CenterViewControllerDelegate?
    let connectionManager = ConnectionManager.sharedManager
    var currentUser: User!
    var theList: List!
    
    
    var tempArray:[String] = ["Banana", "Apple"]       //DELETE ME: This is a temporary array for testing reasons.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, -5)
        
        
        //TODO: Uncomment after setting up login
        //currentUser = connectionManager.getUserFor(userUID: connectionManager.userUID()!)
        
        

        // connectionManager.user
        
//        connectionManager.test()
//        currentUser = connectionManager.
//        
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue())
//        {
//        self.theList = self.connectionManager.getListFor(listUID: self.currentUser.userLists[0].listUID) //FIX THIS ONCE WE HAVE A BETTER IDEA OF LISTS
//        }

    }


    @IBAction func onSettingsButtonTapped(sender: UIBarButtonItem)
    {
    menuDelegate?.toggleLeftPanel?()
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
        if theList.items.count > 1
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
        
        cell.nameLabel.text = tempArray[indexPath.row]
        
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if theList != nil
        {
        return theList.items.count
        }
        return tempArray.count
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        cell.preservesSuperviewLayoutMargins = false
//        cell.layoutMargins = UIEdgeInsetsZero
//    }
    

}
