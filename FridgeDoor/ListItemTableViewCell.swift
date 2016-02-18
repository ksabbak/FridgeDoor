//
//  ListItemTableViewCell.swift
//  FridgeDoor
//
//  Created by K Sabbak on 2/17/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class ListItemTableViewCell: UITableViewCell {

    
    @IBOutlet weak var checkboxImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var topIcon: UIImageView!
    @IBOutlet weak var bottomIcon: UIImageView!
    @IBOutlet weak var volunteerAvatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        checkboxImage.image = UIImage(imageLiteral: "check")
        topIcon.image = UIImage(imageLiteral: "bubble")
        bottomIcon.image = UIImage(imageLiteral: "staple")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
