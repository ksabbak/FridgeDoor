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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var iconLeftConstraint: NSLayoutConstraint!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.appLightBlueColor()
        view.backgroundColor = UIColor.appLightBlueColor()
        
        let screenRect: CGRect = UIScreen.mainScreen().bounds
        let screenWidth: CGFloat = screenRect.size.width
        let centerControl: CGFloat = 92
        iconLeftConstraint.constant = screenWidth/2 - centerControl
        
        //let currentUser = connectionManager.getUserFor(userUID: connectionManager.userUID()!)
        
        //NOTE: These are the titles of the cell.textLabel in the SettingsVC AND the name of the segue
        self.settingsList = ["Profile", "Add Member", "View History", "Switch List", "Create New List", "About"]
        
        connectionManager.getUserFor(connectionManager.userUID()!) { (currentUser: User) -> Void in
            
            print("PENDING REQUESTS???????????????????????? \n\(currentUser.pending)")
        
            //"About" will always be last. If there's a pending request, it will be inserted before "About". Conditional for if there's a pending request at all, and also for the "s" at the end of request(s).
            if currentUser.pending.count > 1
            {
                self.settingsList.insert("Pending Requests: \(currentUser.pending.count)", atIndex: self.settingsList.indexOf("About")!)
            }
            else if currentUser.pending.count > 0
            {
                self.settingsList.insert("Pending Request: \(currentUser.pending.count)", atIndex: self.settingsList.indexOf("About")!)
            }
            self.tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return settingsList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath)
        
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.appLightBlueColor()
        
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
