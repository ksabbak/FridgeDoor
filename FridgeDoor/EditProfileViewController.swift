//
//  EditProfileViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController
{
    
    var avatarImageName = String()

    override func viewDidLoad()
    {
        super.viewDidLoad()


    }
    
    override func viewWillAppear(animated: Bool)
    {
        //if avatarImage = ""
        //then userImage = image
        //else
        //imageView = avatarImageName
    }

    
    @IBAction func onSwitchAvatar(segue: UIStoryboardSegue)
    {
        //Unwinds to EditProfileVC from AvatarVC
    }
    
}
