//
//  CommentTableViewCell.swift
//  FridgeDoor
//
//  Created by Steven Fellows on 2/26/16.
//  Copyright © 2016 MobileMakers. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell, UITextViewDelegate
{
    
    @IBOutlet weak var userImageView: UIImageView?
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    var comment: Comment!
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureWithComment(comment: Comment)
    {
        self.comment = comment
        let user = ConnectionManager.sharedManager.getUserFor(userUID: comment.userUID)
        usernameLabel.text = user!.username
        usernameLabel.textColor = UIColor.appLightBlueColor()
        let date = NSDate()
        let time = Int(date.timeIntervalSinceDate(comment.time))
        let (d, h, m, s) = secondsToDaysHoursMinutesSeconds(time)
        if d < 1
        {
            if h < 1
            {
                if m < 1
                {
                    timeLabel.text = "\(s)s"
                }
                else
                {
                    timeLabel.text = "\(m)m"
                }
            }
            else
            {
                timeLabel.text = "\(h)h"
            }
        }
        else
        {
            timeLabel.text = "\(d)d"
        }
        
        
        userImageView!.image = user?.image
        commentTextView.delegate = self
        commentTextView.text = comment.message
        let fixedWidth = commentTextView.frame.size.width
        let newSize = commentTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = commentTextView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        commentTextView.frame = newFrame;
        commentTextView.scrollEnabled = false
        
        
        
    }
    
    func secondsToDaysHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int, Int) {
        return (seconds / 86400, seconds / 3600, seconds / 60, seconds)
    }
    
}
