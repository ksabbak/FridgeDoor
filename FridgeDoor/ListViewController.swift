//
//  ListViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

@objc
protocol CenterViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func toggleRightPanel()
    optional func collapseSidePanels()
}

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var delegate: CenterViewControllerDelegate?

    
    var tempArray:[String] = []       //DELETE ME: This is a temporary array for testing reasons.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func onSettingsButtonTapped(sender: UIBarButtonItem)
    {
    delegate?.toggleLeftPanel?()
    }

    
    
    @IBAction func onAddButtonTapped(sender: UIBarButtonItem)
    {
        let addAlert = UIAlertController(title: "Add Item", message: "Add item below or select from your history", preferredStyle: UIAlertControllerStyle.Alert)
        
        addAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Item name"
        }
        
        let okayAction = UIAlertAction(title: "Okay", style: .Default ) { (UIAlertAction) -> Void in
            self.tempArray.append((addAlert.textFields?.first?.text)!)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (UIAlertAction) -> Void in
        }
        
        addAlert.addAction(okayAction)
        addAlert.addAction(cancelAction)
        
        
        presentViewController(addAlert, animated: true, completion: nil);
    }
    
    
    
    
    //MARK: - Tableview delegate stuff
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID")!
        
        cell.textLabel?.text = tempArray[indexPath.row]
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tempArray.count
    }
    

}
