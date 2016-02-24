//
//  ProfileViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailAddressLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let connectionManager = ConnectionManager.sharedManager
    var passedUser: User?
    var lists = [List]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }

    override func viewWillAppear(animated: Bool)
    {
        configureWithUser(passedUser!)
    }
    
    func configureWithUser(user: User)
    {
        usernameLabel.text = user.username
        emailAddressLabel.text = user.email
        imageView.image = UIImage(named: "\(user.imageName)")
        let userLists = user.userLists
        for userList in userLists
        {
            let listUID = userList.listUID
            let list = connectionManager.getListFor(listUID: listUID)
            self.lists.append(list!)
        }
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return lists.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID")
        let list = lists[indexPath.row]
        cell?.textLabel?.text = list.name
        
        return cell!
    }
    
    @IBAction func onLogOutTapped(sender: UIBarButtonItem)
    {
        connectionManager.logout()
    }
    
    @IBAction func onEditProfileTapped(sender: UIButton)
    {
        
    }
    
}
