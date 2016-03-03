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
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = UIImage(named: "FridgeDoorLogoSmall")
        navigationItem.titleView = imageView
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        tableView.backgroundColor = UIColor.appVeryLightBlueColor()
    }

    

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return listHistory.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("CellID", forIndexPath: indexPath) as? HistoryTableViewCell else { return UITableViewCell() }

            listHistory.sortInPlace({ $0.time.timeIntervalSince1970 > $1.time.timeIntervalSince1970 })
            let historyItem = listHistory[indexPath.row]
            cell.configureWithHistoryItem(historyItem)
                    
        return cell
    }
    

   
}
