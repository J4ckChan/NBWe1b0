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
    
    //image Array (max:9)
    @IBOutlet weak var imageViewOne: UIImageView!
    
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
    
    func calculateBasicCell(cell:NBWTableViewBasicCell,hasImage:Bool) -> CGFloat{
        
        let headerHeight:CGFloat = 40
        
        let bodyLabelHeight:CGFloat = cell.bodyTextLabel.frame.height
        
        let spacingHeight:CGFloat = 8
        
        let imageHeight:CGFloat = cell.imageViewOne.frame.height
        
        let bottomHeight:CGFloat = 32 + 10
        
        var cellHeight:CGFloat?
        if hasImage == true  {
            cellHeight = headerHeight + bodyLabelHeight + imageHeight + spacingHeight * 3 + bottomHeight + 10
        }else{
            cellHeight = headerHeight + bodyLabelHeight  + spacingHeight * 3 + bottomHeight + 10
        }
        
        print("The Height of Cell is: \(cellHeight)\n bodyLabelHeigt:\(bodyLabelHeight)\n imageHeight:\(imageHeight)")
        
        return cellHeight!
    }
    
    func configureHomeTableViewBasicCell(cell:NBWTableViewBasicCell,weiboStatus:WeiboStatus,tableView:UITableView,hasImage:Bool){
        
        //Setup Header
        cell.thumbnailHeadImageView.sd_setImageWithURL(NSURL(string: (weiboStatus.user?.avatar_large)!))
        cell.thumbnailHeadImageView.clipsToBounds      = true
        cell.thumbnailHeadImageView.layer.borderWidth  = 1.0
        cell.thumbnailHeadImageView.layer.borderColor  = UIColor.lightGrayColor().CGColor
        cell.thumbnailHeadImageView.layer.cornerRadius = 20
        cell.screenNameLable.text                      = weiboStatus.user?.screen_name
        cell.sourceLabel.text                          = weiboStatus.source
        
        //Setup bodyTextLabel
        cell.bodyTextLabel.text            = weiboStatus.text
        
        let labelText                      = cell.bodyTextLabel.text
        let labelTextNSString              = NSString(CString:labelText!, encoding: NSUTF8StringEncoding)
        
        let labelFont                      = UIFont.systemFontOfSize(17)
        let attributesDictionary           = [NSFontAttributeName:labelFont]
        let labelSize                      = CGSize(width: tableView.frame.width-16, height:CGFloat.max)
        let options:NSStringDrawingOptions = [.UsesLineFragmentOrigin,.UsesFontLeading]
        
        let labelRect                      = labelTextNSString!.boundingRectWithSize(labelSize, options: options, attributes: attributesDictionary,context: nil)
        
        cell.bodyTextLabel.frame           = labelRect
        
        //Setup ImageStackView
        cell.configureSingleImageView(cell, weiboStatus: weiboStatus, hasImage:hasImage)
        
        //Setup bottomView
        
    }

    func configureSingleImageView(cell:NBWTableViewBasicCell,weiboStatus:WeiboStatus,var hasImage:Bool){
        
        if (weiboStatus.bmiddle_pic != nil) {
            cell.imageViewOne.sd_setImageWithURL(NSURL(string: weiboStatus.bmiddle_pic!))
            hasImage = true
        }else{
            cell.imageViewOne.removeFromSuperview()
            hasImage = false
        }
    }
}
