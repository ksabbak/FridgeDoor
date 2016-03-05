//
//  Debug.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/17/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit
struct Debug {
    static func log(message: String, file: String = __FILE__, function: String = __FUNCTION__, line: Int = __LINE__, column: Int = __COLUMN__)
    {
      //  print("Log: \"\(message)\"  ->  File: \(NSURL(string: file)!.lastPathComponent!)  Function: \(function)  LINE: \(line)")
    }
}