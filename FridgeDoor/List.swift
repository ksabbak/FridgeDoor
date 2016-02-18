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

struct Item
{
    var name: String
    var UID: String
    var comments: [Comment]
    var essential: String
    var rotate: [UserTurn]
    
    init()
    {
        name = ""
        UID = ""
        essential = ""
        rotate = []
        comments = []
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
    
    init()
    {
        UID = ""
        name = ""
        members = []
        items = []
    }
}
