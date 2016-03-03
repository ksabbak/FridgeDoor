//
//  ListPickerViewController.swift
//  FridgeDoor
//
//  Created by K Sabbak on 3/2/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class ListPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, ConnectionManagerUserChangesDelegate
{

    @IBOutlet weak var listPicker: UIPickerView!
    @IBOutlet weak var listSwitchButton: UIButton!
    @IBOutlet weak var makeDefaultButton: UIButton!
    
    let connectionManager = ConnectionManager.sharedManager
    var delegate: ListSelectedDelegate?
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        connectionManager.userChangedDelegate = self
        
        view.backgroundColor = UIColor.appVeryLightBlueColor()
    
        listSwitchButton.layer.cornerRadius = 5
        makeDefaultButton.layer.cornerRadius = 5
        
    }
    
    @IBAction func onListButtonTapped(sender: AnyObject)
    {
        let list = getPickerRowAsTuple().1
        
        performSegueWithIdentifier("PickedListUnwind", sender: self)
        
        delegate?.listSelected(list)
    }

    @IBAction func onDefaultButtonTapped(sender: UIButton)
    {
        for list in currentUser.userLists
        {
            if list.defaultList == "true"
            {
                connectionManager.makeUndefault(currentUser.UID, onList: list.listUID)
            }
        }
        connectionManager.makeDefault(currentUser.UID, onList: getPickerRowAsTuple().1)
        
        makeDefaultButton.enabled = false
    }
    
    
    //MARK: - Picker delegate stuff
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentUser.userLists.count
    }
    
    //Number of columns
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString?
    {
        let listTitle = (connectionManager.getListFor(listUID: currentUser.userLists[row].listUID)?.name)!
        let attributedString = NSAttributedString(string: "\(listTitle)", attributes: [NSForegroundColorAttributeName : UIColor.appDarkBlueColor()])
        return attributedString
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let list = currentUser.userLists[row]
        if list.defaultList == "true"
        {
            self.makeDefaultButton.enabled = false
        }
        else
        {
            self.makeDefaultButton.enabled = true
        }
    }
    
    ///Actively gets picker row information
    func getPickerRowAsTuple() -> (String, String)
    {
        let row = listPicker.selectedRowInComponent(0)
        
        let title = connectionManager.getListFor(listUID: currentUser.userLists[row].listUID)?.name
        
        let tupleList = (title!, currentUser.userLists[row].listUID)
        return tupleList
    }
    
    func connectionManagerUserWasChanged(user: User)
    {
        if user.UID == currentUser.UID
        {
            currentUser = user
            
            listPicker.reloadAllComponents()
        }
    }


    
}
