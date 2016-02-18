//
//  User.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/16/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import Foundation
import UIKit

class User
{
    var UID: String
    var username: String
    var email: String
    var imageName: String
    var image: UIImage
    
    init(username: String, email: String, imageName: String)
    {
        UID           = ""
        self.username = username
        self.email    = email
        self.imageName = imageName
        self.image    = UIImage(named: "\(imageName)")
    }
}