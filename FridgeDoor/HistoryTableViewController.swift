//
//  HistoryTableViewController.swift
//  FridgeDoor
//
//  Created by K Sabbak on 2/29/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {

    var listHistory = [History]()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
    }

    

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listHistory.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID", forIndexPath: indexPath)

        if listHistory.count > 0
        {
            cell.textLabel?.text = listHistory[indexPath.row].itemName
        }
        
        return cell
    }
    

   
}
