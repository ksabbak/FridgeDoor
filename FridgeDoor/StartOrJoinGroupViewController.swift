//
//  StartOrJoinGroupViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class StartOrJoinGroupViewController: UIViewController
{

    var currentUser: User?
    let connectionManager = ConnectionManager.sharedManager
    
    @IBOutlet weak var joinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentUser!.pending.count > 0
        {
           joinButton.enabled = true
        }
        else
        {
            joinButton.enabled = false
            joinButton.backgroundColor = UIColor.appDarkBlueColor()
        }

    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "CreateNewGroup"
        {
            let dvc = segue.destinationViewController as! CreateGroupViewController
            
            dvc.leepFrog = true
            
            dvc.currentUser = currentUser
        }
        
        if segue.identifier == "NewJoinerSegue"
        {
            let dvc = segue.destinationViewController as! JoinTableViewController
            
            dvc.dismiss = true
            dvc.currentUser = currentUser
        }
    }
    
    @IBAction func leepFrogSegue(segue: UIStoryboardSegue)
    {
        //Unwinds to StartOrJoinVC from CreateGroupVC
        performSegueWithIdentifier("FroggerTwoSegue", sender: nil)
    }

}
