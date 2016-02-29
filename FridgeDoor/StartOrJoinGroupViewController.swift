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
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "CreateNewGroup"
        {
            let dvc = segue.destinationViewController as! CreateGroupViewController
            
            dvc.leepFrog = true
            
            dvc.currentUser = currentUser
        }
    }
    
    @IBAction func leepFrogSegue(segue: UIStoryboardSegue)
    {
        //Unwinds to StartOrJoinVC from CreateGroupVC
        performSegueWithIdentifier("FroggerTwoSegue", sender: nil)
    }

}
