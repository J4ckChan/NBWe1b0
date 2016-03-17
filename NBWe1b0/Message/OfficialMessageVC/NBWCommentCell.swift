//
//  NBWCommentCell.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/16/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWCommentCell: UITableViewCell {
    
    @IBOutlet weak var avater: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    
    //WeiboStatus BriefView
    @IBOutlet weak var weiboStatusBriefView: UIView!
    @IBOutlet weak var weiboStatusImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func replyCommentInCommentCell(sender: UIButton) {
        let cell = sender.superview?.superview as! UITableViewCell
        NSNotificationCenter.defaultCenter().postNotificationName("ReplyComment", object: cell)
    }
    
}
