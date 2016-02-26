//
//  DetailsViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var voluteerToPurchaseButton: UIButton!
    @IBOutlet weak var volunteerImage: UIImageView!
    @IBOutlet weak var essentialButton: UIButton!
    @IBOutlet weak var rotateButton: UIButton!
    @IBOutlet weak var addCommentTextField: UITextField!
    @IBOutlet weak var sendCommentButton: UIButton!
    @IBOutlet weak var lastPurchasedByLabel: UILabel!
    
    var list: List!
    var item: Item!
    var comments: [Comment] = []
    var currentUserInRotation: User?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addCommentTextField.delegate = self
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
    }


    override func viewWillAppear(animated: Bool)
    {
        configureWithItem(item)
        tableView.reloadData()
    }

    func configureWithItem (item: Item)
    {
        print("Item name: \(item.name)")
        itemNameLabel.text = item.name
        itemNameLabel.textColor = UIColor.appLightBlueColor()
        if item.rotating == "true"
        {
            print("rotating item is true")
            var userTurnUID = String()
            rotateButton.setImage(UIImage(named: "check"), forState: .Normal)
            for userTurn in item.rotate
            {
                if userTurn.turn == "1"
                {
                    print("The rotate current user is found")
                    print("userTurnUID: \(userTurn.userTurnUID)")
                    userTurnUID = userTurn.userTurnUID
                }
            }
            self.currentUserInRotation = ConnectionManager.sharedManager.getUserFor(userUID: userTurnUID)!
            print("User: \(self.currentUserInRotation)")
            volunteerImage.image = UIImage(named: "\(self.currentUserInRotation!.imageName)")
            voluteerToPurchaseButton.titleLabel!.text = "Currently assigned to \(self.currentUserInRotation!.username)"
        }
        
    }
    
    @IBAction func onBoughtButtonTapped(sender: UIButton)
    {
    
    
    }
    
    @IBAction func onCancelButtonTapped(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return item.comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        guard let cell: CommentTableViewCell = tableView.dequeueReusableCellWithIdentifier("CellID") as? CommentTableViewCell else { return UITableViewCell() }
        item.comments.sortInPlace({ $0.time.timeIntervalSince1970 > $1.time.timeIntervalSince1970 })
        let comment = item.comments[indexPath.row]
        cell.configureWithComment(comment)
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if (editingStyle == UITableViewCellEditingStyle.Delete)
        {
            let comment = item.comments[indexPath.row]
            ConnectionManager.sharedManager.deleteComment(comment.UID, fromItem: item.UID, onList: list.UID)
            item.comments.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }
    
    @IBAction func sendButtonTapped(sender: UIButton)
    {
        let commentString = addCommentTextField.text
        ConnectionManager.sharedManager.addComment(commentString!, toItem: item.UID, onList: list.UID)
        
        let userUID = ConnectionManager.sharedManager.userUID()
        let comment = Comment(time: NSDate().timeIntervalSince1970, userUID: userUID!, message: commentString!, UID: "")
        item.comments.append(comment)
        
        addCommentTextField.text = ""
        addCommentTextField.resignFirstResponder()
        tableView.reloadData()
    }

    @IBAction func onScreenTapped(sender: UITapGestureRecognizer)
    {
        addCommentTextField.resignFirstResponder()
    }

    @IBAction func highAlertTapped(sender: UIButton)
    {
        
    }
    
    @IBAction func essentialTapped(sender: UIButton)
    {
        
    }
    
    @IBAction func rotateTapped(sender: UIButton)
    {
        if item.rotating.characters.count == 0
        {
            var memberDictionary = [String:String]()
            let currentUserUID = ConnectionManager.sharedManager.userUID()
            var i = 2
            for member in list.members
            {
                if member.userUID != currentUserUID
                {
                    let twople = ("\(member.userUID)" , "\(i)")
                    memberDictionary[twople.0] = twople.1
                    i = i + 1
                }
            }
            print("member dictionary: \(memberDictionary)")
            
            ConnectionManager.sharedManager.setUpRotatingItem(currentUserUID!, itemUID: item.UID, onList: list.UID, memberUIDsAndOrder: memberDictionary)
            item.rotating = "true"
            sender.setImage(UIImage(named: "check"), forState: .Normal)
            let currentUser: User = ConnectionManager.sharedManager.getUserFor(userUID: currentUserUID!)!
            self.currentUserInRotation = currentUser
            volunteerImage.image = UIImage(named: "\(self.currentUserInRotation!.imageName)")
        }
        else if item.rotating == "true"
        {
            print("should change image to box")
            item.rotating = "false"
            sender.setImage(UIImage(named: "box"), forState: .Normal)
            ConnectionManager.sharedManager.rotatingOff(item.UID, onList: list.UID)
            volunteerImage.image = UIImage(named: "gray")
        }
        else if item.rotating == "false"
        {
            print("should change image to check")
            item.rotating = "true"
            sender.setImage(UIImage(named: "check"), forState: .Normal)
            ConnectionManager.sharedManager.rotatingOn(item.UID, onList: list.UID)
            volunteerImage.image = UIImage(named: "\(self.currentUserInRotation!.imageName)")
        }
        
    }
    
    @IBAction func volunteerTapped(sender: UIButton)
    {
        
    }
    
    
    

}
