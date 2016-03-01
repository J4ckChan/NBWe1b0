//
//  NBWOfficialTableViewCell.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/1/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWOfficialTableViewCell: UITableViewCell {

    @IBOutlet weak var avater: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    let officialMessageArray = ["Mentions","Comments","Likes","Subscribe Messages","Stranger's Messages"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureOfficialTableViewCell(cell:NBWOfficialTableViewCell,indexPath:NSIndexPath){
        
        nameLabel.text = officialMessageArray[indexPath.row]
        
        if indexPath.row == 0 {
            avater.image = UIImage(named: "message_at")
        }else if indexPath.row == 1 {
            avater.image = UIImage(named: "message_comment")
        }else if indexPath.row == 2 {
            avater.image = UIImage(named: "message_like")
        }else if indexPath.row == 3 {
            avater.image = UIImage(named: "message_subscribe")
        }else if indexPath.row == 4 {
            avater.image = UIImage(named: "message_email")
        }
        
        avater.clipsToBounds = true
        avater.layer.cornerRadius = 25
        
    }

}
