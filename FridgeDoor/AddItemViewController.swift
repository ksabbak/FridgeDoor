//
//  AddItemViewController.swift
//  FridgeDoor
//
//  Created by K Sabbak on 2/17/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

protocol AddItemBackButtonDelegate {
    func backButtonDataReload()
}


class AddItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ConnectionManagerAddItemDelegate, ConnectionManagerListChangesDelegate
{
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let connectionManager = ConnectionManager.sharedManager
    var backbuttonDelegate: AddItemBackButtonDelegate?
    
    var list: List!
    var chosenItems = [Item]()
    //var displayItems = [Item]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        searchBar.autocapitalizationType = UITextAutocapitalizationType.None
        connectionManager.addItemDelegate = self
        connectionManager.listChangedDelegate = self
        chosenItems = list.items
        
        tableView.backgroundColor = UIColor.appVeryLightBlueColor()
        tableView.separatorColor = UIColor.appDarkBlueColor()
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = UIImage(named: "FridgeDoorLogoSmall")
        navigationItem.titleView = imageView
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
        if searchBar.text?.characters.count > 0
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
            searchBar.text = ""
            searchBar.resignFirstResponder()
            tableView.reloadData()
        
        }
    }
    
    
    
    func connectionManagerDidAddItem()
    {
        print("added item")
        list = connectionManager.getListFor(listUID: list.UID)
        
        //Resets search bar text field after item is added.
        searchBarCancelButtonClicked(searchBar)
        chosenItems = list.items
        searchBar.resignFirstResponder()
        
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
        
        cell.backgroundColor = UIColor.appVeryLightBlueColor()
        
        
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
    
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        resignFirstResponder()
    }
    
    func connectionManagerListWasChanged(list: List)
    {
        if self.list.UID == list.UID
        {
            self.list = list
            //connectionManager.setupMemberObservers(theList)
            
            getDisplayItems()
        }
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        backbuttonDelegate?.backButtonDataReload()
        print("I'm getting really sick of this nonsense. I really think someone should make this easier, thanks.")
        
        super.viewWillDisappear(animated)
    }
    
}