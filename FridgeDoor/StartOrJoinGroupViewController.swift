//
//  StartOrJoinGroupViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class StartOrJoinGroupViewController: UIViewController, ConnectionManagerLogOutDelegate
{

    var currentUser: User?
    let connectionManager = ConnectionManager.sharedManager
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool)
    {
        connectionManager.logoutDelegate = self
    }

    

    @IBAction func onLogOutTapped(sender: UIButton)
    {
        connectionManager.logout()
    }
    
    func connectionManagerDidLogOut()
    {
       dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "CreateNewGroup"
        {
            let dvc = segue.destinationViewController as! CreateGroupViewController
            dvc.currentUser = currentUser
        }
    }
}
