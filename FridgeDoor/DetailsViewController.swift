//
//  DetailsViewController.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ConnectionManagerItemChangedDelegate
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
    @IBOutlet weak var highAlertButton: UIButton!
    
    let connectionManager = ConnectionManager.sharedManager
    
    var list: List!
    var item: Item!
    var comments: [Comment] = []
    var currentUserInRotation: User?
    var currentUser: User?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addCommentTextField.delegate = self
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        ConnectionManager.sharedManager.itemChangedDelegate = self
        ConnectionManager.sharedManager.setupItemObserver(item.UID, listUID: list.UID)
        
        
        
        
        
        
        //Start code that fills in the "last bought by" info on the bottom
        list.historyItems.sortInPlace({ $0.time.timeIntervalSince1970 > $1.time.timeIntervalSince1970 })
        
        for historyItem in list.historyItems
        {
            if historyItem.itemName == item.name
            {
                connectionManager.getUserFor(historyItem.purchaserUID, completion: { (user: User) -> Void in
                    
                    let date = NSDate()
                    let time = Int(date.timeIntervalSinceDate(historyItem.time))
                    let (d, h, m, s) = self.secondsToDaysHoursMinutesSeconds(time)
                    var timeSince = ""
                    if d < 1
                    {
                        if h < 1
                        {
                            if m < 1
                            {
                                timeSince = "just now"
                            }
                            else
                            {
                                timeSince = "\(m) minutes ago"
                            }
                        }
                        else
                        {
                            if h > 1
                            {
                            timeSince = "\(h) hours ago"
                            }
                            else
                            {
                                timeSince = "\(h) hour ago"
                            }
                        }
                    }
                    else
                    {
                        if d > 1
                        {
                            timeSince = "\(d) days ago"
                        }
                        else
                        {
                            timeSince = "\(d) day ago"
                        }
                    }
 
                    self.lastPurchasedByLabel.text = "Last purchased by \(user.username) " + timeSince + "."
                })
                break
            }
        }
        //End code that fills in the "last bought by" code at the bottom. If no previous purchase was made, it will be blank.
        
    }


    override func viewWillAppear(animated: Bool)
    {
        configureWithItem(item)
    }

    func configureWithItem (item: Item)
    {
        iconImageView.image = UIImage(named: pickImage())
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
//            self.currentUserInRotation = ConnectionManager.sharedManager.getUserFor(userUID: userTurnUID)
            ConnectionManager.sharedManager.getUserFor(userTurnUID, completion: { (user: User) -> Void in
                self.volunteerImage.image = UIImage(named: "\(user.imageName)")
                self.voluteerToPurchaseButton.enabled = false
                self.voluteerToPurchaseButton.backgroundColor = UIColor.appDarkBlueColor()
                self.voluteerToPurchaseButton.setTitle("Assigned to \(user.username)", forState: .Normal)
            })
                
                
            
        }
        
        if item.rotating == "false" || item.rotating == ""
        {
            rotateButton.setImage(UIImage(named: "box"), forState: .Normal)
            if item.rotating == "false"
            {
                print("rotating item is false")
                var userTurnUID = String()
                for userTurn in item.rotate
                {
                    if userTurn.turn == "1"
                    {
                        print("The rotate current user is found")
                        print("userTurnUID: \(userTurn.userTurnUID)")
                        userTurnUID = userTurn.userTurnUID
                    }
                }
                self.currentUserInRotation = ConnectionManager.sharedManager.getUserFor(userUID: userTurnUID)
                print("User: \(self.currentUserInRotation)")
            }
           
            if item.volunteerUID == ""
            {
                rotateButton.enabled = true
                print("no volunteer found")
                voluteerToPurchaseButton.backgroundColor = UIColor.appWineColor()
                voluteerToPurchaseButton.setTitle("Volunteer to Purchase", forState: .Normal)
                voluteerToPurchaseButton.enabled = true
                volunteerImage.image = UIImage(named: "lightGray")
            }
            
            if item.volunteerUID.characters.count > 0
            {
                rotateButton.enabled = false
                print("volunteer is found, assigning")
                if item.volunteerUID == currentUser!.UID
                {
                    voluteerToPurchaseButton.backgroundColor = UIColor.appLightBlueColor()
                    voluteerToPurchaseButton.setTitle("Undo Volunteer", forState: .Normal)
                    voluteerToPurchaseButton.enabled = true
                    volunteerImage.image = UIImage(named: "\(currentUser!.imageName)")
                }
                else
                {
                    let volunteer = ConnectionManager.sharedManager.getUserFor(userUID: item.volunteerUID)
                    voluteerToPurchaseButton.backgroundColor = UIColor.appLightBlueColor()
                    voluteerToPurchaseButton.setTitle("\(volunteer!.username) has volunteered", forState: .Normal)
                    voluteerToPurchaseButton.enabled = false
                    volunteerImage.image = UIImage(named: "\(volunteer!.imageName)")
                }
            }
        }
        
        if item.highAlert == "true"
        {
            print("Configure as High Alert item")
            highAlertButton.setImage(UIImage(named: "check"), forState: .Normal)
        }
        
        if item.essential == "true"
        {
            print("Configure as Essential item")
            essentialButton.setImage(UIImage(named: "check"), forState: .Normal)
        }
        
        tableView.reloadData()
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
        
        addCommentTextField.text = ""
        addCommentTextField.resignFirstResponder()
    }
    
    func connectionmanagerDidFailToSetUpComment()
    {
        print("Didn't set up the comments")
    }

    @IBAction func onScreenTapped(sender: UITapGestureRecognizer)
    {
        addCommentTextField.resignFirstResponder()
    }

    @IBAction func highAlertTapped(sender: UIButton)
    {
        if item.highAlert == "true"
        {
            print("should uncheck high alert box")
            ConnectionManager.sharedManager.unmarkHighAlert(item.UID, fromList: list.UID)
            highAlertButton.setImage(UIImage(named: "box"), forState: .Normal)
            item.highAlert = "false"
            return
        }
        if item.highAlert == "false" || item.highAlert == ""
        {
            print("should check high alert box")
            ConnectionManager.sharedManager.markAsHighAlert(item.UID, onList: list.UID)
            highAlertButton.setImage(UIImage(named: "check"), forState: .Normal)
            item.highAlert = "true"
            return
        }
    }
    
    @IBAction func essentialTapped(sender: UIButton)
    {
        if item.essential == "true"
        {
            print("should uncheck essential box")
            ConnectionManager.sharedManager.unmarkEssential(item.UID, fromList: list.UID)
            essentialButton.setImage(UIImage(named: "box"), forState: .Normal)
            item.essential = "false"
            return
        }
        if item.essential == "false" || item.essential == ""
        {
            print("should check essential box")
            ConnectionManager.sharedManager.markAsEssential(item.UID, onList: list.UID)
            essentialButton.setImage(UIImage(named: "check"), forState: .Normal)
            item.essential = "true"
            return
        }
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
                    memberDictionary["\(member.userUID)"] = "\(i)"
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
            volunteerImage.image = UIImage(named: "lightGray")
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
        print("voluteerTapped")
        if item.volunteerUID == ""
        {
            print("should set volunteer")
            ConnectionManager.sharedManager.volunteer(currentUser!.UID, forItem: item.UID, onList: list.UID)
        }
        if item.volunteerUID == currentUser!.UID
        {
            print("should remove volunteer")
            ConnectionManager.sharedManager.unvolunteer(currentUser!.UID, forItem: item.UID, fromList: list.UID)
        }
    }
    
    func connectionManagerItemWasChanged(item: Item)
    {
        if self.item.UID == item.UID
        {
            self.item = item
            self.configureWithItem(item)
        }
    }
    
    //Seconds is not really ever used, but hey, it's here if we need it.
    func secondsToDaysHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int, Int) {
        return (seconds / 86400, seconds / 3600, seconds / 60, seconds)
    }

    
    //MARK: - Icon Image Picker
    
    func pickImage() -> String
    {
        
        let itemImages = ["apple", "avocado",
            "banana", "bread", "bacon", "blueberry", "bowl",
            "cookie", "cake", "carrot", "cheese", "cherry", "chicken", "coffee", "cereal", "chip",
            "egg",
            "garbagebag",
            "juice", "jar",
            "lettuce",
            "milk",
            "orange",
            "paper", "pineapple", "pea", "potato",
            "raspberry",
            "shampoo", "soap", "soda", "strawberry",
            "tomato"]
        
        var simpleName = item.name.lowercaseString
        
        simpleName = simpleName.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        if item.name.characters.last == "s"
        {
            simpleName = item.name.substringToIndex(item.name.endIndex.predecessor()).lowercaseString
            
            if simpleName.characters.last == "e" && simpleName.characters[simpleName.endIndex.advancedBy(-2)] == "i"
            {
                
                simpleName = item.name.substringToIndex(item.name.endIndex.advancedBy(-3)).lowercaseString + "y"
                print("Yes, Kessica, this fucking worked. I honestly don't know how you are even functioning right now. \(simpleName)")
            }
        }
        
        for image in itemImages
        {
            if simpleName == image
            {
                return image
            }
            else if simpleName.containsString(image) && simpleName != "grapefruit"
            {
                return image
            }
        }
        
        if simpleName == "lemon"
            || simpleName == "lime"
            || simpleName == "grapefruit"
            || simpleName == "citrus"
            || simpleName == "clementine"
            || simpleName == "tangerine"
        {
            return "orange"
        }
        
        if simpleName == "pop"
            || simpleName == "coke"
            || simpleName == "pepsi"
            || simpleName == "sprite"
            || simpleName == "cola"
            || simpleName == "gingerale"
            || simpleName.containsString("beer")
            || simpleName == "drink"
        {
            return "soda"
        }
        
        let hotDrinks = ["hotchocolate", "tea", "chai", "cocoa"]
        for drink in hotDrinks
        {
            if simpleName.containsString(drink)
            {
                return "coffee"
            }
        }
        
        let greenArray = ["spinach", "kale", "collard", "chard", "cabbage", "salad"]
        for green in greenArray
        {
            if simpleName.containsString(green)
            {
                return "lettuce"
            }
        }
        
        let jarArray = ["jelly", "jam", "nutb", "cashewb", "almondb", "salsa", "pesto"]
        for jar in jarArray
        {
            if simpleName.containsString(jar)
            {
                return "jar"
            }
        }
        
        let candyArray = ["snicker", "reese", "milkyway", "chocolate", "skittle", "m&m", "kitkat", "jellybean", "hershey"]
        for candy in candyArray
        {
            if simpleName.containsString(candy)
            {
                return "candy"
            }
        }
        
        let chickenArray = ["turkey", "poultry"]
        for meat in chickenArray
        {
            if simpleName.containsString(meat)
            {
                return "chicken"
            }
        }
        
        let meatArray = ["pork", "meat", "jerky", "ham", "salami", "pepperoni"]
        for meat in meatArray
        {
            if simpleName.containsString(meat)
            {
                return "bacon"
            }
        }
        
        if simpleName == "conditioner"
        {
            return "shampoo"
        }
        
        if simpleName.containsString("bean")
        {
            return "pea"
        }
        
        
        let cheeseArray = ["swis", "cheddar", "muenster", "mozzarella", "brie", "camembert", "chevre", "parmesan", "romano", "asiago"]
        for cheese in cheeseArray
        {
            if simpleName.containsString(cheese)
            {
                return "cheese"
            }
        }
        
        let cereals = ["cheerio", "crunch", "chex", "life"]
        for cereal in cereals
        {
            if simpleName.containsString(cereal)
            {
                return "cereal"
            }
        }
        
        let bowlItems = ["soup", "campbell", "oatmeal", "progresso"]
        for bowl in bowlItems
        {
            if simpleName.containsString(bowl)
            {
                return "bowl"
            }
        }
        
        if simpleName.containsString("trash")
        {
            return "garbagebag"
        }
        
        if simpleName.containsString("guac")
        {
            return "avocado"
        }
        
        if simpleName.containsString("pie")
        {
            return "cake"
        }
        
        
        if arc4random_uniform(2) == 0
        {
            return "other1"
        }
        
        
        
        return "other2"
    }
    

}