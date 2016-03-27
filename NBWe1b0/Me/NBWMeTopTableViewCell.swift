//
//  NBWMeTopTableViewCell.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/23/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWMeTopTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avater: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var weiboNumLabel: UILabel!
    @IBOutlet weak var followerNumLabel: UILabel!
    @IBOutlet weak var followNumLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
