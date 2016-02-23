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
   
    override func viewDidLoad()
    {
        super.viewDidLoad()

        searchBar.autocapitalizationType = UITextAutocapitalizationType.None
        connectionManager.addItemDelegate = self
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (searchText.isEmpty == false)
        {
            let searchString = searchBar.text! as String
            searchTextArray(searchString)
        }
        
        tableView.reloadData()
    }
    
    
    func searchTextArray(searchText: String)
    {
        
        
    }

    
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
    
        self.connectionManager.addItem(self.searchBar.text!, toList: self.list.UID)
    
    }
    
    func connectionManagerDidAddItem()
    {
        print("added item")
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

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID")!
        
        cell.textLabel?.text = list.items[indexPath.row].name
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return list.items.count
    }
    
    
    

    
}
