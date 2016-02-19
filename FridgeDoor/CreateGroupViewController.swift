//
//  CreateGroupViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class CreateGroupViewController: UIViewController {

    @IBOutlet weak var listTitleTextField: UITextField!
   
    let connectionManager = ConnectionManager.sharedManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

    }


    

    @IBAction func onCreateButtonTapped(sender: UIButton)
    {
        
        //STEVE. Shouldn't this get passed the title or Something??
        let newList = List()
        
        
        connectionManager.createList(newList)
        
        
    }


}
