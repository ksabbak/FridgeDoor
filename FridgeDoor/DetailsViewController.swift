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
    
    
    var item: Item!
    var comments: [Comment] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        
        
        
    }

    override func viewWillAppear(animated: Bool)
    {
        configureWithItem(item)
    }

    func configureWithItem (item: Item)
    {
        itemNameLabel.text = item.name
        
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


}
