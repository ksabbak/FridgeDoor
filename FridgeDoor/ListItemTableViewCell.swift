//
//  ListItemTableViewCell.swift
//  FridgeDoor
//
//  Created by K Sabbak on 2/17/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

protocol ListItemTableViewCellDelegate
{
    func didTapButton(cell: ListItemTableViewCell)
}


class ListItemTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var topIcon: UIImageView!
    @IBOutlet weak var bottomIcon: UIImageView!
    @IBOutlet weak var volunteerAvatar: UIImageView!
    
    var delegate: ListItemTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        topIcon.image = UIImage(named: "bubble")
        bottomIcon.image = UIImage(named: "staple")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    //Should this be here??? Should this be here as a delegate thing? Probably that. Think it through.
    @IBAction func onCheckButtonTapped(sender: UIButton)
    {
        delegate?.didTapButton(self)
        

    }
}
