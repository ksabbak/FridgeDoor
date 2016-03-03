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
        
        self.settingsList = ["Profile", "Add Member", "View History", "Switch List", "Create New List"]
        
        connectionManager.getUserFor(connectionManager.userUID()!) { (currentUser: User) -> Void in
            
            print("PENDING REQUESTS???????????????????????? \n\(currentUser.pending)")
            
            
            //NOTE: These are the titles of the cell.textLabel in the SettingsVC AND the name of the segue
            
            
            
            if currentUser.pending.count > 1
            {
                self.settingsList.append("Pending Requests: \(currentUser.pending.count)")
            }
            else if currentUser.pending.count > 0
            {
                self.settingsList.append("Pending Request: \(currentUser.pending.count)")
            }
            self.tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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







