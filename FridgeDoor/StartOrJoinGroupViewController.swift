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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
