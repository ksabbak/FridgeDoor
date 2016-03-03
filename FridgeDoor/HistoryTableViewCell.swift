//
//  HistoryTableViewCell.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 3/1/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell
{

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var purchasedByLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

    
    }
    
    func configureWithHistoryItem(historyItem: History)
    {
        ConnectionManager.sharedManager.getUserFor(historyItem.purchaserUID, completion: { (purchaser: User) -> Void in
            
            
            self.avatarImageView.image = UIImage(named: "\(purchaser.imageName)")
            self.itemNameLabel.text = historyItem.itemName
            self.purchasedByLabel.text = "Purchased by: \(purchaser.username)"
            
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            self.dateLabel.text = "\(formatter.stringFromDate(historyItem.time))"
            self.backgroundColor = UIColor.appVeryLightBlueColor()
        })

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
