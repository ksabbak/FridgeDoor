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
    let connectionManager = ConnectionManager.sharedManager

    
    
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
            let historyItem = listHistory[indexPath.row]
            connectionManager.getUserFor(historyItem.purchaserUID, completion: { (purchaser: User) -> Void in
            
            
            cell.textLabel?.text = historyItem.itemName
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            formatter.stringFromDate(historyItem.time)
            
            cell.detailTextLabel?.text = "Purchased by: \(purchaser.username) on: \(formatter.stringFromDate(historyItem.time))"
            })
        }
        
        return cell
    }
    

   
}
