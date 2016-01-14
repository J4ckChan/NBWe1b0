//
//  NBWTableViewBasicCell.swift
//  NBWe1b0
//
//  Created by ChanLiang on 1/14/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWTableViewBasicCell: UITableViewCell {

    @IBOutlet weak var thumbnailHeadImageView: UIImageView!
    @IBOutlet weak var screenNameLable: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var bodyTextLabel: UILabel!
    
    var bodyText:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
