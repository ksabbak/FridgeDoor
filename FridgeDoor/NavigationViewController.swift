//
//  NavigationViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 3/1/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
  
}
