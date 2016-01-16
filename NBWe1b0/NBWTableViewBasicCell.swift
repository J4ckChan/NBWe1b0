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
    
    // 3 imageStackView
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var imageStack2: UIStackView!
    @IBOutlet weak var imageStack3: UIStackView!
    
    //image Array (max:9)
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var imageViewTwo: UIImageView!
    @IBOutlet weak var imageViewThree: UIImageView!
    @IBOutlet weak var imageViewFour: UIImageView!
    @IBOutlet weak var imageViewFive: UIImageView!
    @IBOutlet weak var imageViewSix: UIImageView!
    @IBOutlet weak var imageViewSeven: UIImageView!
    @IBOutlet weak var imageViewEight: UIImageView!
    @IBOutlet weak var imageViewNine: UIImageView!
    
    //repsot & comment & like
    @IBOutlet weak var repostCount: UILabel!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var likeCout: UILabel!
    
    var bodyText:String?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func repostWeibo(sender: UIButton) {
    }
    
    @IBAction func commentWeibo(sender: UIButton) {
    }
    
    @IBAction func likeWeibo(sender: UIButton) {
    }
    
}
