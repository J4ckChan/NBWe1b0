//
//  NBWTableViewImageCell.swift
//  NBWe1b0
//
//  Created by ChanLiang on 1/21/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWTableViewImageCell: UITableViewCell {

    //headerView
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!    
    @IBOutlet weak var sourceLabel: UILabel!

    //bodyText
    @IBOutlet weak var bodyTextLabel: UILabel!
    
    //imageView
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var imageViewTwo: UIImageView!
    @IBOutlet weak var imageViewThree: UIImageView!
    @IBOutlet weak var imageViewFour: UIImageView!
    @IBOutlet weak var imageViewFive: UIImageView!
    @IBOutlet weak var imageViewSix: UIImageView!
    
    //bottomView
    @IBOutlet weak var countForRepostCommentLikes: UILabel!
    @IBOutlet weak var repostCommentLikeBarView: UIView!
       
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
