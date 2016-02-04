//
//  NBWCommentTableViewCell.swift
//  NBWe1b0
//
//  Created by ChanLiang on 2/4/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWCommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contextView: UIView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var bodyTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCommentTableViewCell(comment:NBWComment){
        
//        print(self.headerImageView)

        self.headerImageView.sd_setImageWithURL(NSURL(string: comment.avatarLargerURL!))
        self.headerImageView.clipsToBounds = true
        self.headerImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.headerImageView.layer.borderWidth = 1
        self.headerImageView.layer.cornerRadius = 20
        
        self.screenNameLabel.text = comment.screenName
        self.createdAt.text       = comment.createdAt
        
        self.bodyTextLabel.text   = comment.text
        
    }
    
}
