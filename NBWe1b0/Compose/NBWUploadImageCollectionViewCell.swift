//
//  NBWUploadImageCollectionViewCell.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/10/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWUploadImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var circleTag: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    var selectedBool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
