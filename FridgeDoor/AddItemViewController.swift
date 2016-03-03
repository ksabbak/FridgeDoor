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
    var filteredItems = [Item]()
    var topItems = [Item]()
    var regularItems = [Item]()
    var onListItems = [Item]()
    var dictionary = [String : [Item]]()
    var filtering = false
    var itemSections = [ItemSection]()
    
    struct ItemSection
    {
        var sectionName : String!
        var sectionObjects : [Item]!
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        searchBar.autocapitalizationType = UITextAutocapitalizationType.None
//        connectionManager.addItemDelegate = self
        connectionManager.listChangedDelegate = self
        chosenItems = list.items
        
        fillArraysWith(list.items)
        
        tableView.backgroundColor = UIColor.appVeryLightBlueColor()
        tableView.separatorColor = UIColor.appDarkBlueColor()
        //tableView.headerViewForSection(0)?.backgroundColor = UIColor.appLightBlueColor()
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = UIImage(named: "FridgeDoorLogoSmall")
        navigationItem.titleView = imageView
    }
    
    func fillArraysWith(items: [Item])
    {
        onListItems.removeAll()
        topItems.removeAll()
        regularItems.removeAll()
        itemSections.removeAll()
        
        for item in items
        {
            if item.active == "true"
            {
                onListItems.append(item)
            }
            else if item.essential == "true"
            {
                topItems.append(item)
            }
            else
            {
                regularItems.append(item)
            }
        }
        
//        dictionary = ["Add Top Items" : topItems, "Add Items" : regularItems, "On List" : onListItems]
        
        if topItems.count > 0
        {
            itemSections.append(ItemSection(sectionName: "Add Top Items", sectionObjects: topItems))
        }
        if regularItems.count > 0
        {
            itemSections.append(ItemSection(sectionName: "Add Items", sectionObjects: regularItems))
        }
        if onListItems.count > 0
        {
            itemSections.append(ItemSection(sectionName: "On List", sectionObjects: onListItems))
        }
        
        
        tableView.reloadData()

    }
    
    //Starts searching the array.
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        
        if (searchText.isEmpty == false)
        {
            filtering = true
            let searchString = searchBar.text! as String
            searchTextArray(searchString.lowercaseString)
        }
        else
        {
            filtering = false
            fillArraysWith(list.items)
        }
    }
    
    //The actually search check
    func searchTextArray(searchText: String)
    {
        
        filteredItems = []
        
        for item in list.items
        {
            let lowerChar = item.name.lowercaseString
            if lowerChar.containsString(searchText)
            {
                filteredItems.append(item)
            }
        }
        
        fillArraysWith(filteredItems)
        
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
//            tableView.reloadData()
        
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
    
    
    
    //Mark: TableView Functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return itemSections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return itemSections[section].sectionObjects.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return itemSections[section].sectionName
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID")!
        let item = itemSections[indexPath.section].sectionObjects[indexPath.row]
        cell.textLabel?.text = item.name
        cell.backgroundColor = UIColor.appVeryLightBlueColor()
        
        if item.active == "true"
        {
            cell.textLabel?.textColor = UIColor.grayColor()
            cell.userInteractionEnabled = false
            print("\(item.name) is \(item.active) active")
        }
        else
        {
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.userInteractionEnabled = true
            print("\(item.name) is \(item.active) inactive")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let item = itemSections[indexPath.section].sectionObjects[indexPath.row]
        
        connectionManager.makeActive(item.UID, onList: list.UID) { () -> Void in
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.contentView.backgroundColor = UIColor.appLightBlueColor()
        
        headerView.textLabel?.textColor = UIColor.whiteColor()
    }
    
    
//    func getDisplayItems() -> [Item]
//    {
//        var displayItems = [Item]()
//        
//        for item in (connectionManager.getListFor(listUID: list.UID)?.items)!
//        {
//            if chosenItems.contains(item)
//            {
//                if item.active == ""
//                {
//                    displayItems.insert(item, atIndex: 0)
//                }
//                else
//                {
//                    displayItems.append(item)
//                }
//            }
//        }
//        
//        chosenItems = displayItems
//        
//        return displayItems
//    }
    
    
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
            fillArraysWith(list.items)
            tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        backbuttonDelegate?.backButtonDataReload()
        print("I'm getting really sick of this nonsense. I really think someone should make this easier, thanks.")
        
        super.viewWillDisappear(animated)
    }
    
}

//var breeds = ["A": ["Affenpoo", "Affenpug", "Affenshire", "Affenwich", "Afghan Collie", "Afghan Hound"], "B": ["Bagle Hound", "Boxer"]]
//
//struct Objects {
//    var sectionName : String!
//    var sectionObjects : [String]!
//}
//
//var objectArray = [Objects]()
//
//override func viewDidLoad() {
//    super.viewDidLoad()
//
//    tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
//    // SORTING [SINCE A DICTIONARY IS AN UNSORTED LIST]
//    var sortedBreeds = sorted(breeds) { $0.0 < $1.0 }
//    for (key, value) in sortedBreeds {
//        println("\(key) -> \(value)")
//        objectArray.append(Objects(sectionName: key, sectionObjects: value))
//    }
//}
//
//override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//    return objectArray.count
//}
//
//override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return objectArray[section].sectionObjects.count
//}
//
//override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
//    // SETTING UP YOUR CELL
//    cell.textLabel?.text = objectArray[indexPath.section].sectionObjects[indexPath.row]
//    return cell
//}
//
//override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//    return objectArray[section].sectionName
//}
//
//
//}