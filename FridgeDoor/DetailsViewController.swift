//
//  DetailsViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    
    var item: Item!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        itemNameLabel.text = item.name
        
    }


    @IBAction func onBoughtButtonTapped(sender: UIButton)
    {
    
    
    }
    
    @IBAction func onCancelButtonTapped(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
