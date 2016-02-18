//
//  History.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/17/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import Foundation
import UIKit

class History
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