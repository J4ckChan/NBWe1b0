//
//  NBWFollowerTableViewCell.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/1/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWFollowerTableViewCell: UITableViewCell {

    @IBOutlet weak var avater: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
