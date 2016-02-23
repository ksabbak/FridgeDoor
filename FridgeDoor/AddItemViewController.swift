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
    var displayItems = [Item]()
   
    override func viewDidLoad()
    {
        super.viewDidLoad()

        searchBar.autocapitalizationType = UITextAutocapitalizationType.None
        connectionManager.addItemDelegate = self
        
        displayItems = list.items
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
            displayItems = list.items
        }

        
        tableView.reloadData()
    }
    
    //The actually search check
    func searchTextArray(searchText: String)
    {
        
        displayItems = []
        
        for item in list.items
        {
            let lowerChar = item.name.lowercaseString
            if lowerChar.containsString(searchText)
            {
                displayItems.append(item)
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
        displayItems = list.items
        
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
        
        cell.textLabel?.text = displayItems[indexPath.row].name
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return displayItems.count
    }
    
    
    

    
}
