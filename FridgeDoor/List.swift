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
    var userTurn: Bool
    
    init()
    {
        userTurn = false
    }
}

struct Item
{
    var name: String
    var comments: [Comment]
    var essential: Bool
    var rotate: [UserTurn]
    
    init(name: String)
    {
        self.name = name
        essential = false
        rotate = []
        comments = []
    }
}

class List
{
    
    var UID: String
    var name: String
    var members: [String]
    var items: [Item]
    
    init()
    {
        UID = ""
        name = ""
        members = []
        items = []
    }
}
