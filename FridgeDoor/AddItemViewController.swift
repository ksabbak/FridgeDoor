//
//  AddItemViewController.swift
//  FridgeDoor
//
//  Created by K Sabbak on 2/17/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.autocapitalizationType = UITextAutocapitalizationType.None
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

    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID")!
        
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 0
    }
    
    
    

    
}
