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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func calculateImageCell(cell:NBWTableViewImageCell,numberOfImageRow:CGFloat) -> CGFloat{
        
        let headerHeight:CGFloat = 40
        
        let bodyLabelHeight:CGFloat = cell.bodyTextLabel.frame.height
        
        let spacingHeight:CGFloat = 8
        
        let imageHeight:CGFloat = cell.imageViewOne.frame.height
        
        let bottomHeight:CGFloat = 32 + 8
        
        let cellHeight = headerHeight + bodyLabelHeight + imageHeight * numberOfImageRow + spacingHeight * 3 + bottomHeight + 12
            
        print("The Height of Cell is: \(cellHeight)\n bodyLabelHeigt:\(bodyLabelHeight)\n imageHeight:\(imageHeight * numberOfImageRow)")
        
        return cellHeight
    }
    
    func configureMultiImageCell(cell:NBWTableViewImageCell,weiboStatus:WeiboStatus,tableView:UITableView){
        
        //Setup Header
        cell.headerImageView.sd_setImageWithURL(NSURL(string: (weiboStatus.user?.avatar_large)!))
        cell.headerImageView.clipsToBounds      = true
        cell.headerImageView.layer.borderWidth  = 1.0
        cell.headerImageView.layer.borderColor  = UIColor.lightGrayColor().CGColor
        cell.headerImageView.layer.cornerRadius = 20
        cell.screenNameLabel.text                      = weiboStatus.user?.screen_name
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
        configureMultiImageView(cell, weiboStatus: weiboStatus)
        
        //Setup bottomView
        
    }
    
    func configureMultiImageView(cell:NBWTableViewImageCell,weiboStatus:WeiboStatus){
        
        let imageViewArray = [cell.imageViewOne,cell.imageViewTwo,cell.imageViewThree,cell.imageViewFour,cell.imageViewFive,cell.imageViewSix]
        
        let weiboStatusSet = weiboStatus.pics as! Set<WeiboStatusPics>
        
        let picsCount      = weiboStatusSet.count
        
        if  picsCount == 2 || picsCount == 3{
 
            var count = 0
            for weiboStatusPic in  weiboStatusSet {
                imageViewArray[count].sd_setImageWithURL(NSURL(string:weiboStatusPic.pic!))
                count += 1
            }
            
            for var i = 3; i < 6; i = i+1 {
                imageViewArray[i].removeFromSuperview()
            }
            
        }else if picsCount == 4 {
            
            var count = 0
            for WeiboStatusPic in weiboStatusSet {
               imageViewArray[count].sd_setImageWithURL(NSURL(string: WeiboStatusPic.pic!))
                count += 1
                if count == 2 {
                    count = 3
                }
            }
            
        }else if  picsCount == 5 || picsCount == 6 {

            var count = 0
            for weiboStatusPic in  weiboStatusSet {
                imageViewArray[count].sd_setImageWithURL(NSURL(string:weiboStatusPic.pic!))
                count += 1
            }
        }
    }
}
