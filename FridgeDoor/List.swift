//
//  List.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import Foundation
import UIKit

struct Comment
{
    var userUID: String
    var time: NSDate
    var message: String
    var UID: String
    init(time: Double, userUID: String, message: String, UID: String)
    {
        self.time = NSDate(timeIntervalSince1970: time)
        self.userUID = userUID
        self.message = message
        self.UID = UID
    }
}

struct UserTurn {
    var userTurnUID: String
    
    init()
    {
        userTurnUID = ""
    }
}

struct Item: Equatable
{
    var name: String
    var UID: String
    var active: String
    var comments: [Comment]
    var essential: String
    var highAlert: String
    var volunteerUID: String
    var rotate: [UserTurn]
    
    init(name: String)
    {
        self.name = name
        UID = ""
        active = ""
        essential = ""
        highAlert = ""
        volunteerUID = ""
        rotate = []
        comments = []
    }
}
    func ==(firstElement: Item, secondElement: Item) -> Bool
    {
        return firstElement.UID == secondElement.UID
    }


struct History
{
    var UID: String
    var itemName: String
    var purchaserUID: String
    var listUID: String
    var time: NSDate
    
    init(itemName: String, purchaserUID: String, listUID: String, time: Double)
    {
        UID           = ""
        self.itemName = itemName
        self.purchaserUID = purchaserUID
        self.listUID  = listUID
        self.time = NSDate(timeIntervalSince1970: time)
    }
}

struct Member
{
    var userUID: String
    var time: NSDate
    init(time: String, userUID: String)
    {
        self.time = NSDate(timeIntervalSince1970: Double(time)!)
        self.userUID = userUID
    }
}

class List
{
    
    var UID: String
    var name: String
    var members: [Member]
    var items: [Item]
    var historyItems: [History]
    
    init(name: String)
    {
        UID = ""
        self.name = name
        members = []
        items = []
        historyItems = []
    }
}
