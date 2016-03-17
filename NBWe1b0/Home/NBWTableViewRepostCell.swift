//
//  NBWTableViewRepostCell.swift
//  NBWe1b0
//
//  Created by ChanLiang on 1/22/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWTableViewRepostCell: UITableViewCell {
    
    //header
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    
    //TextLabel
    @IBOutlet weak var bodyTextLabel: UILabel!
    
    //RepostStatus
    @IBOutlet weak var repostView: UIView!
    @IBOutlet weak var repostTextLabel: UILabel!
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var imageViewTwo: UIImageView!
    @IBOutlet weak var imageViewThree: UIImageView!
    @IBOutlet weak var imageViewFour: UIImageView!
    @IBOutlet weak var imageViewFive: UIImageView!
    @IBOutlet weak var imageViewSix: UIImageView!
    
    //bottom
    @IBOutlet weak var countForRepostComemntLike: UILabel!
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
