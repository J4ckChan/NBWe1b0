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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func calculateRepostCellHeight(cell:NBWTableViewRepostCell,numberOfImageRow:CGFloat) -> CGFloat{
        
        let headerHeight:CGFloat = 40
        
        let bodyLabelHeight:CGFloat = cell.bodyTextLabel.frame.height
        
        let spacingHeight:CGFloat = 8
        
        let repostTextLabelHeight:CGFloat = cell.repostTextLabel.frame.height
        
        var imageHeight:CGFloat?
        if numberOfImageRow == 1 {
            imageHeight = (cell.imageViewOne.frame.height + 8) * numberOfImageRow
        }else if numberOfImageRow == 2{
           imageHeight = (cell.imageViewOne.frame.height  + 8) * numberOfImageRow
        }else{
            imageHeight = 0
        }
        
        let repostHeight:CGFloat = repostTextLabelHeight + 8 + imageHeight!
        
        let bottomHeight:CGFloat = 67 // 17 + 8 + 32 + 10
        
        let cellHeight = headerHeight + bodyLabelHeight + repostHeight + spacingHeight * 5 + bottomHeight

        print("The Height of Cell is: \(cellHeight)\n bodyLabelHeigt:\(bodyLabelHeight) repostLabelHeight:\(repostTextLabelHeight)\n )")
        
        return cellHeight
    }
    
    func configureRespostCell(cell:NBWTableViewRepostCell,weiboStatus:WeiboStatus,tableView:UITableView,numberOfImageRow:CGFloat){
        
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
        let labelSize                      = CGSize(width: tableView.frame.width - 16, height:CGFloat.max)
        let options:NSStringDrawingOptions = [.UsesLineFragmentOrigin,.UsesFontLeading]
        
        let labelRect                      = labelTextNSString!.boundingRectWithSize(labelSize, options: options, attributes: attributesDictionary,context: nil)
        
        cell.bodyTextLabel.frame           = labelRect
        
        //Setup repostTextLabel
        cell.repostTextLabel.text      = "@\((weiboStatus.retweeted_status?.user?.screen_name)!):\((weiboStatus.retweeted_status?.text)!)"

        let repostLabelText            = cell.repostTextLabel.text
        let repostLabelNSString        = NSString(CString: repostLabelText!, encoding: NSUTF8StringEncoding)

        let repostLabelFont            = UIFont.systemFontOfSize(15)
        let repostAttributesDictionary = [NSFontAttributeName:repostLabelFont]

        let repostLabelRect            = repostLabelNSString!.boundingRectWithSize(labelSize, options: options, attributes: repostAttributesDictionary, context: nil)

        cell.repostTextLabel.frame     = repostLabelRect
        
        //Setup ImageStackView
        configureRepostStatusImageView(cell, weiboStatus: weiboStatus.retweeted_status!)

        //Setup bottomView
        cell.countForRepostComemntLike.text = "\((weiboStatus.retweeted_status?.reposts_count)!) Repost, \((weiboStatus.retweeted_status?.comments_count)!) Comments, \((weiboStatus.retweeted_status?.attitudes_count)!) Likes"
        
    }
    
    func configureRepostStatusImageView(cell:NBWTableViewRepostCell,weiboStatus:WeiboStatus){
        
        let imageViewArray = [cell.imageViewOne,cell.imageViewTwo,cell.imageViewThree,cell.imageViewFour,cell.imageViewFive,cell.imageViewSix]
        
        let weiboStatusSet = weiboStatus.pics as! Set<WeiboStatusPics>
        
        let picsCount      = weiboStatusSet.count
        
        if picsCount == 0 {
            
            for imageViewPic in imageViewArray {
                imageViewPic?.removeFromSuperview()
            }
            
        }else if  picsCount == 1 || picsCount == 2 || picsCount == 3{
            
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
            
        }else if  picsCount > 4 && picsCount < 10{
            
            var count = 0
            for weiboStatusPic in  weiboStatusSet {
                imageViewArray[count].sd_setImageWithURL(NSURL(string:weiboStatusPic.pic!))
                count += 1
                if count > 5 {
                    break
                }
            }
        }
    }


}
