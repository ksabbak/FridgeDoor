//
//  ProfileViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

protocol ListSelectedDelegate
{
    func listSelected(listUID: String)
}

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ConnectionManagerLogOutDelegate, UITextFieldDelegate
{

    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var selectAvatarButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailAddressLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let connectionManager = ConnectionManager.sharedManager
    var passedUser: User?
    var lists = [List]()
    var delegate: ListSelectedDelegate?
    var inEditMode = false
    var avatarImageName = String()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        connectionManager.logoutDelegate = self
        view.backgroundColor = UIColor.appVeryLightBlueColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = UIImage(named: "FridgeDoorLogoSmall")
        navigationItem.titleView = imageView
    }

    override func viewWillAppear(animated: Bool)
    {
        usernameTextField.delegate = self
        
        configureWithUser(passedUser!)
        tableView.backgroundColor = UIColor.appVeryLightBlueColor()
    }
    
    func configureWithUser(user: User)
    {
        if !(inEditMode)
        {
            usernameTextField.hidden = true
            selectAvatarButton.hidden = true
            selectAvatarButton.enabled = false
            editProfileButton.setTitle("Edit Profile", forState: .Normal)
            avatarImageName = user.imageName
        }
        
        usernameLabel.text = user.username
        emailAddressLabel.text = user.email
        imageView.image = UIImage(named: "\(avatarImageName)")
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
        cell?.textLabel?.textColor = UIColor.appBrownColor()
        cell?.backgroundColor = UIColor.appVeryLightBlueColor()
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let list = lists[indexPath.row]
        delegate?.listSelected(list.UID)
    }
    
    @IBAction func onLogOutTapped(sender: UIBarButtonItem)
    {
        connectionManager.logout()
    }
    
    func connectionManagerDidLogOut()
    {
        print("perform segue to Logout")
        performSegueWithIdentifier("ProfileLogout", sender: nil)
    }
    
    
    @IBAction func onEditProfileTapped(sender: UIButton)
    {
        if editProfileButton.titleLabel!.text == "Edit Profile"
        {
            inEditMode = true
            editProfileButton.setTitle("Done", forState: .Normal)
            imageView.image = UIImage(named: "lightGray")
            usernameLabel.hidden = true
            selectAvatarButton.enabled = true
            selectAvatarButton.hidden = false
            usernameTextField.hidden = false
            usernameTextField.text = usernameLabel.text
        }
        else
        {
            passedUser?.username = usernameTextField.text!
            passedUser?.imageName = avatarImageName
            connectionManager.updateUser(passedUser!)
            selectAvatarButton.enabled = false
            selectAvatarButton.hidden = true
            imageView.image = UIImage(named: "\(avatarImageName)")
            editProfileButton.setTitle("Edit Profile", forState: .Normal)
            usernameTextField.hidden = true
            usernameLabel.hidden = false
            usernameLabel.text = passedUser?.username
            inEditMode = false
        }
    }
    
    
    @IBAction func onSelectAvatarTapped(sender: UIButton)
    {
        performSegueWithIdentifier("ProfileToAvatar", sender: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "ProfileToAvatar"
        {
            let dvc = segue.destinationViewController as! AvatarViewController
            dvc.editAvatar = true
        }
    }
    
    @IBAction func onSwitchAvatar(segue: UIStoryboardSegue)
    {
        //Unwinds to EditProfileVC from AvatarVC
    }

    
}
