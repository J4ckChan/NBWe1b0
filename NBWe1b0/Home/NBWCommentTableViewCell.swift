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
    
    func configureCommentTableViewCell(comment:NBWComment,viewWidth:CGFloat){

        self.headerImageView.sd_setImageWithURL(NSURL(string: comment.avatarLargerURL!))
        self.headerImageView.clipsToBounds = true
        self.headerImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.headerImageView.layer.borderWidth = 1
        self.headerImageView.layer.cornerRadius = 20
        
        self.screenNameLabel.text = comment.screenName
        self.createdAt.text       = comment.createdAt
        
        self.bodyTextLabel.text   = comment.text
        self.bodyTextLabel.numberOfLines = 0
        
        let labelText = comment.text
        let labelTextNSString = NSString(CString: labelText!, encoding: NSUTF8StringEncoding)
        
        let labelFont = UIFont.systemFontOfSize(17)
        let attributesDictionary = [NSFontAttributeName:labelFont]
        let labelSize = CGSize(width: viewWidth - 56, height: CGFloat.max)
        
        let options:NSStringDrawingOptions = [.UsesLineFragmentOrigin,.UsesFontLeading]
        
        let labelRect = labelTextNSString?.boundingRectWithSize(labelSize, options: options, attributes: attributesDictionary , context: nil)
        
        self.bodyTextLabel.frame = labelRect!
    }
    
}
