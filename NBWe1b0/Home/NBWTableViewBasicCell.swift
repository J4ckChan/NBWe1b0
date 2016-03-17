//
//  NBWTableViewBasicCell.swift
//  NBWe1b0
//
//  Created by ChanLiang on 1/14/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWTableViewBasicCell: UITableViewCell {

    //header
    @IBOutlet weak var thumbnailHeadImageView: UIImageView!
    @IBOutlet weak var screenNameLable: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    
    //bodyLable
    @IBOutlet weak var bodyTextLabel: UILabel!
    
    //image
    @IBOutlet weak var imageViewOne: UIImageView!
    
    //repsot & comment & like
    @IBOutlet weak var countForRepostCommentLike: UILabel!
    @IBOutlet weak var repostCommentLikeBarView: UIView!
    
    //MARK: - View
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
