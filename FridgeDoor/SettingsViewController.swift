//
//  SettingsViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit


class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath)
        
        return cell
    }


}





//class SidePanelViewController: UIViewController {
//    
//    @IBOutlet weak var tableView: UITableView!
//    
//    var animals: Array<Animal>!
//    
//    struct TableView {
//        struct CellIdentifiers {
//            static let AnimalCell = "AnimalCell"
//        }
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        tableView.reloadData()
//    }
//    
//}

// MARK: Table View Data Source

//extension SidePanelViewController: UITableViewDataSource {
//    
//    
//}

// Mark: Table View Delegate

//extension SidePanelViewController: UITableViewDelegate {
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//    }
//    
//}


