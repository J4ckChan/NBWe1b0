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
    var repostCommentLikeBar:UIView?
    var repostButton:UIButton?
    var commentButton:UIButton?
    var likeButton:UIButton?
    var likeFlag:Bool?
    
    var bodyText:String?
    
    var viewController:NBWHomeViewController?
    
    //MARK: - View
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
        
        let bottomHeight:CGFloat = 67 // 17 + 8 + 32 + 10
        
        var cellHeight:CGFloat?
        if hasImage == true  {
            cellHeight = headerHeight + bodyLabelHeight + imageHeight + spacingHeight * 4 + bottomHeight
        }else{
            cellHeight = headerHeight + bodyLabelHeight  + spacingHeight * 3 + bottomHeight
        }
        
//        print("The Height of Cell is: \(cellHeight)\n bodyLabelHeigt:\(bodyLabelHeight)\n imageHeight:\(imageHeight)")
        
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
        cell.countForRepostCommentLike.text = "\((weiboStatus.reposts_count)!) Repost, \((weiboStatus.comments_count)!) Comment, \((weiboStatus.attitudes_count)!) Likes"
        
        //Setup repostCommentLikeBar
        setupRespotCommentLikeBarView()
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
    
    //MARK: - Repost & Comment & Like Bar
    func setupRespotCommentLikeBarView(){
        self.repostButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: tableViewCellWidth!/3.0, height: 32))
        self.repostButton?.setTitle("  Repost", forState: UIControlState.Normal)
        self.repostButton?.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        self.repostButton?.titleLabel?.font = UIFont.systemFontOfSize(15)
        self.repostButton?.setImage(UIImage(named: "repost32"), forState: .Normal)
        self.repostButton?.addTarget(self.viewController, action: Selector("repostWeiboStatus"), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.commentButton = UIButton.init(frame: CGRect(x: tableViewCellWidth!/3.0, y: 0, width: tableViewCellWidth!/3.0, height: 32))
        self.commentButton?.setTitle("  Comment", forState: .Normal)
        self.commentButton?.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        self.commentButton?.titleLabel?.font = UIFont.systemFontOfSize(15)
        self.commentButton?.setImage(UIImage(named: "comment32"), forState: .Normal)
        self.commentButton?.addTarget(self, action: Selector("commentWeiboStatus"), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.likeButton = UIButton.init(frame: CGRect(x: (tableViewCellWidth!/3.0)*2, y: 0, width: tableViewCellWidth!/3.0, height: 32))
        self.likeButton?.setTitle("  like", forState: .Normal)
        self.likeButton?.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        self.likeButton?.titleLabel?.font = UIFont.systemFontOfSize(15)
        self.likeButton?.setImage(UIImage(named: "like32"), forState: .Normal)
        self.likeButton?.addTarget(self, action: Selector("likeWeiboStatus"), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.likeFlag = false
        
        let separator1 = UIView(frame: CGRect(x: tableViewCellWidth!/3.0, y: 13, width: 1, height: 16))
        separator1.backgroundColor = UIColor.lightGrayColor()
        
        let separator2 = UIView(frame: CGRect(x: 2.0*tableViewCellWidth!/3.0, y: 13, width: 1, height: 16))
        separator2.backgroundColor = UIColor.lightGrayColor()
        
        let separator3 = UIView(frame: CGRect(x: 0, y: 32, width: tableViewCellWidth!, height: 10))
        separator3.backgroundColor = UIColor(red: 242/250, green: 242/250, blue: 242/250, alpha: 1)
        
        self.repostCommentLikeBarView.addSubview(self.repostButton!)
        self.repostCommentLikeBarView.addSubview(self.commentButton!)
        self.repostCommentLikeBarView.addSubview(self.likeButton!)
        self.repostCommentLikeBarView.addSubview(separator1)
        self.repostCommentLikeBarView.addSubview(separator2)
        self.repostCommentLikeBarView.addSubview(separator3)
    }
}
