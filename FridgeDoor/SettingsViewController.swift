//
//  SettingsViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

protocol PerformSeguesForSettingsVCDelegate
{
    func settingTapped(setting: String)
}


class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var performSeguesForSettingsVCDelegate: PerformSeguesForSettingsVCDelegate?
    var settingsList = [String]()
    let connectionManager = ConnectionManager.sharedManager
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let currentUser = connectionManager.getUserFor(userUID: connectionManager.userUID()!)
        
        print("PENDING REQUESTS???????????????????????? \n\(currentUser!.pending)")
        
        
        //NOTE: These are the titles of the cell.textLabel in the SettingsVC AND the name of the segue
        settingsList = ["Profile", "Add Member", "View History", "Create New List"]
        
        
        if currentUser?.pending.count > 1
        {
            settingsList.append("Pending Requests: \(currentUser!.pending.count)")
        }
        else if currentUser?.pending.count > 0
        {
            settingsList.append("Pending Request: \(currentUser!.pending.count)")
        }

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath)
        let settingName = settingsList[indexPath.row]
        cell.textLabel?.text = settingName
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var setting = settingsList[indexPath.row]
        
        if setting.containsString(":")
        {
            setting = "Pending"
        }
     
            performSeguesForSettingsVCDelegate!.settingTapped(setting)

    }

}







