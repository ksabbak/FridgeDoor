//
//  User.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//


import Foundation
import UIKit


struct UserList
{
    var listUID: String
    var time: NSDate
     var defaultList: String
    
    init(time: String, listUID: String)
    {
        self.time = NSDate(timeIntervalSince1970: Double(time)!)
        self.listUID = listUID
        defaultList = ""
    }
    
    init(time: String, listUID: String, defaultList: String)
    {
        self.time = NSDate(timeIntervalSince1970: Double(time)!)
        self.listUID = listUID
        self.defaultList = defaultList
    }
}

class User
{
    var UID: String
    var username: String
    var email: String
    var imageName: String
    var image: UIImage
    var userLists: [UserList]
    var pending: [[String:String]]
    
    init(username: String, email: String, imageName: String)
    {
        UID           = ""
        self.username = username
        self.email    = email
        self.imageName = imageName
        self.image    = UIImage(named: "\(imageName)")!
        userLists = []
        pending = []
    }
}
