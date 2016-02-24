//
//  AddItemViewController.swift
//  FridgeDoor
//
//  Created by K Sabbak on 2/17/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ConnectionManagerAddItemDelegate
{

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let connectionManager = ConnectionManager.sharedManager
    
    var list: List!
    var chosenItems = [Item]()
    //var displayItems = [Item]()
   
    override func viewDidLoad()
    {
        super.viewDidLoad()

        searchBar.autocapitalizationType = UITextAutocapitalizationType.None
        connectionManager.addItemDelegate = self
        
        chosenItems = list.items
    }
    
    //Starts searching the array.
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (searchText.isEmpty == false)
        {
            let searchString = searchBar.text! as String
            searchTextArray(searchString.lowercaseString)
        }
        else
        {
            chosenItems = list.items
        }

        
        tableView.reloadData()
    }
    
    //The actually search check
    func searchTextArray(searchText: String)
    {
        
        chosenItems = []
        
        for item in list.items
        {
            let lowerChar = item.name.lowercaseString
            if lowerChar.containsString(searchText)
            {
                chosenItems.append(item)
            }
        }
        
    }

    //Will check add item against all items in list, 
    //If no item exists, it's added
    //If item exists, an Alert gets triggered and user has the option to overwrite existing item
    @IBAction func onAddItemButtonTapped(sender: UIButton)
    {
        if list.items.count > 0
        {
            
            for item in list.items
            {
                if item.name.lowercaseString == searchBar.text?.lowercaseString
                {
                    replaceItemAlert(item)
                    return
                }
            }
        }
    
        connectionManager.addItem(searchBar.text!, toList: list.UID)
        
        
    }
    
    func connectionManagerDidAddItem()
    {
        print("added item")
        list = connectionManager.getListFor(listUID: list.UID)
        
        //Resets search bar text field after item is added.
        searchBar.text = ""
        
        //Adds things back to the table
        chosenItems = list.items
        
        tableView.reloadData()

    }
    
    func connectionManagerDidFailToAddItem()
    {
        print("failed to add item")
    }
    

    func replaceItemAlert(item: Item)
    {
        let replaceAlert = UIAlertController(title: "Item Already Exists", message: "An item with this name already exists, do you want to replace the item and all its data with this new item?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let okayAction = UIAlertAction(title: "Replace Item", style: .Default ) { (UIAlertAction) -> Void in
            self.connectionManager.deleteItem(item.UID, fromList: self.list.UID)
            self.connectionManager.addItem(self.searchBar.text!, toList: self.list.UID)
            print("It's a mystery!")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel ) { (UIAlertAction) -> Void in
        }
        
        replaceAlert.addAction(okayAction)
        replaceAlert.addAction(cancelAction)
        
        presentViewController(replaceAlert, animated: true, completion: nil);
    }

    
    
    //Right now just displays item name
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID")!
        
        let displayItems = getDisplayItems()
        
        let item = displayItems[indexPath.row]
        
        cell.textLabel?.text = item.name
        
        
        if item.active != ""
        {
            cell.textLabel?.textColor = UIColor.grayColor()
            cell.detailTextLabel?.textColor = UIColor.grayColor()
            cell.detailTextLabel?.text = "This item is already on your list"
            cell.userInteractionEnabled = false
            print("\(item.name) is \(item.active) active")
        }
        else
        {
            cell.detailTextLabel?.text = ""
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.userInteractionEnabled = true
            print("\(item.name) is \(item.active) inactive")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let item = chosenItems[indexPath.row]
    
        connectionManager.makeActive(item.UID, onList: list.UID) { () -> Void in
            tableView.reloadData()
        }
    
        
//        tableView.reloadData()
//        print("FIRE!" + "\(item.active)!")
        

    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return chosenItems.count
    }
    
    
    func getDisplayItems() -> [Item]
    {
        var displayItems = [Item]()
        
        for item in (connectionManager.getListFor(listUID: list.UID)?.items)!
        {
            if chosenItems.contains(item)
            {
                if item.active == ""
                {
                displayItems.insert(item, atIndex: 0)
                }
                else
                {
                    displayItems.append(item)
                }
            }
        }
        
        chosenItems = displayItems
        
        return displayItems
    }

    
}
