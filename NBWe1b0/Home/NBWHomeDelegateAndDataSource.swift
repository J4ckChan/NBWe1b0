//
//  NBWHomeDelegateAndDataSource.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/17/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

protocol PushViewControllerDelegate{
    func pushViewController(vc:UIViewController)
}

enum HomeTableViewCellType {
    case BasicCell
    case ImageCell
    case RepostCell
}

class NBWHomeDelegateAndDataSource: NSObject {
    
    let basicReuseIdentifier      = "BasicCell"
    let multiImageReuseIdentifier = "ImageCell"
    let repostReuseIdentifier     = "RepostCell"
    
    var weiboStatusesArray = [WeiboStatus]()
    var weiboStatus:WeiboStatus?
    var cellType:HomeTableViewCellType?
    var heightArray = [CGFloat]()
    var likeFlag = false
    var tableView:UITableView?
    var selectedWeiboStatus:WeiboStatus?
    var delegate:PushViewControllerDelegate?
    
    //MARK: - Init
    init(array:[WeiboStatus]) {
        super.init()
        self.weiboStatusesArray = array
    }
    
    //Check homeCell Type
    func homeCellType(weiboStatus:WeiboStatus)->HomeTableViewCellType{
        
        if weiboStatus.retweeted_status != nil {
            return HomeTableViewCellType.RepostCell
        }else{
            if weiboStatus.pics?.count < 2 {
                return HomeTableViewCellType.BasicCell
            }else{
                return HomeTableViewCellType.ImageCell
            }
        }
    }
}


//MARK: - UITableViewDataSource
extension NBWHomeDelegateAndDataSource:UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView = tableView
        return weiboStatusesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        weiboStatus = weiboStatusesArray[indexPath.row]
        cellType = homeCellType(weiboStatus!)
        
        if cellType == HomeTableViewCellType.BasicCell {
           let cell = tableView.dequeueReusableCellWithIdentifier(basicReuseIdentifier, forIndexPath: indexPath) as! NBWTableViewBasicCell
            return cell
        }else if cellType == HomeTableViewCellType.ImageCell{
            let cell = tableView.dequeueReusableCellWithIdentifier(multiImageReuseIdentifier, forIndexPath: indexPath) as! NBWTableViewImageCell
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier(repostReuseIdentifier, forIndexPath: indexPath) as! NBWTableViewRepostCell
            return cell
        }
    }
}


//MARK: - UITableViewDelegate
extension NBWHomeDelegateAndDataSource:UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let weiboStatus = weiboStatusesArray[indexPath.row]
        
        let weiboContextBasicViewController = NBWeiboContextBasicViewController.init(id: weiboStatus.id!,tableViewBool: false)
        weiboContextBasicViewController.hidesBottomBarWhenPushed = true
        delegate?.pushViewController(weiboContextBasicViewController)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cellHeight:CGFloat?
        weiboStatus = weiboStatusesArray[indexPath.row]
        cellType = homeCellType(weiboStatus!)
        if heightArray.count == weiboStatusesArray.count {
            return heightArray[indexPath.row]
        }else{
            if cellType == HomeTableViewCellType.BasicCell {
                cellHeight = calculateBasicCell(weiboStatus!)
            }else if cellType == HomeTableViewCellType.ImageCell {
                cellHeight = calculateImageCell(weiboStatus!)
            }else{
                cellHeight = calculateRepostCellHeight(weiboStatus!)
            }
        }
        heightArray.append(cellHeight!)
        return cellHeight!
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cellType == HomeTableViewCellType.BasicCell{
            configureHomeBasicCell(cell as! NBWTableViewBasicCell, weiboStatus: weiboStatus!)
        }else if cellType == HomeTableViewCellType.ImageCell{
            configureMultiImageCell(cell as! NBWTableViewImageCell, weiboStatus: weiboStatus!)
        }else{
            configureRespostCell(cell as! NBWTableViewRepostCell, weiboStatus: weiboStatus!)
        }
    }
    
    //MARK: - ConfigureHomeCell
    func configureHomeBasicCell(cell:NBWTableViewBasicCell,weiboStatus:WeiboStatus){
        
        //Setup Header
        cell.thumbnailHeadImageView.sd_setImageWithURL(NSURL(string: (weiboStatus.user?.avatar_large)!))
        cell.screenNameLable.text                      = weiboStatus.user?.screen_name
        cell.sourceLabel.text                          = weiboStatus.source
        
        //Setup bodyTextLabel
        cell.bodyTextLabel.text            = weiboStatus.text
        
        //Setup ImageStackView
        if (weiboStatus.bmiddle_pic != nil) {
            cell.imageViewOne.sd_setImageWithURL(NSURL(string: weiboStatus.bmiddle_pic!))
        }else{
            cell.imageViewOne.removeFromSuperview()
        }
        
        //Setup bottomView
        cell.countForRepostCommentLike.text = "\((weiboStatus.reposts_count)!) Repost, \((weiboStatus.comments_count)!) Comment, \((weiboStatus.attitudes_count)!) Likes"
        
        //Setup repostCommentLikeBar
        setupRespotCommentLikeBarView(cell.repostCommentLikeBarView)
    }
    
    func configureMultiImageCell(cell:NBWTableViewImageCell,weiboStatus:WeiboStatus){
        
        //Setup Header
        cell.headerImageView.sd_setImageWithURL(NSURL(string: (weiboStatus.user?.avatar_large)!))
        cell.screenNameLabel.text                      = weiboStatus.user?.screen_name
        cell.sourceLabel.text                          = weiboStatus.source
        
        //Setup bodyTextLabel
        cell.bodyTextLabel.text            = weiboStatus.text
        
        //Setup ImageStackView
        configureMultiImageView(cell, weiboStatus: weiboStatus)
        
        //Setup bottomView
        cell.countForRepostCommentLikes.text = "\((weiboStatus.reposts_count)!) Repost, \((weiboStatus.comments_count)!) Comment, \((weiboStatus.attitudes_count)!) Likes"
        
        setupRespotCommentLikeBarView(cell.repostCommentLikeBarView)
    }

    func configureRespostCell(cell:NBWTableViewRepostCell,weiboStatus:WeiboStatus){
        
        //Setup Header
        cell.headerImageView.sd_setImageWithURL(NSURL(string: (weiboStatus.user?.avatar_large)!))
        cell.screenNameLabel.text                      = weiboStatus.user?.screen_name
        cell.sourceLabel.text                          = weiboStatus.source
        
        //Setup bodyTextLabel
        cell.bodyTextLabel.text            = weiboStatus.text
       
        //Setup repostTextLabel
        cell.repostTextLabel.text      = "@\((weiboStatus.retweeted_status?.user?.screen_name)!):\((weiboStatus.retweeted_status?.text)!)"
        
        //Setup ImageStackView
        configureRepostStatusImageView(cell, weiboStatus: weiboStatus.retweeted_status!)
        
        //Setup bottomView
        cell.countForRepostComemntLike.text = "\((weiboStatus.retweeted_status?.reposts_count)!) Repost, \((weiboStatus.retweeted_status?.comments_count)!) Comments, \((weiboStatus.retweeted_status?.attitudes_count)!) Likes"
        
        setupRespotCommentLikeBarView(cell.repostCommentLikeBarView)
    }
    
    //configureCellImage
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
    
    func configureRepostStatusImageView(cell:NBWTableViewRepostCell,weiboStatus:WeiboStatus){
        let imageViewArray = [cell.imageViewOne,cell.imageViewTwo,cell.imageViewThree,cell.imageViewFour,cell.imageViewFive,cell.imageViewSix]
        let weiboStatusSet = weiboStatus.pics as! Set<WeiboStatusPics>
        let picsCount      = weiboStatusSet.count
        
        if picsCount == 0 {
            for imageViewPic in imageViewArray {
                imageViewPic?.removeFromSuperview()
            }
        }else if  picsCount > 0 && picsCount < 4 {
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
    
    func setupRespotCommentLikeBarView(repostCommentLikeBarView:UIView){
        
        let repostButton = UIButton.init(frame: CGRect(x: 0, y: 1, width: tableViewCellWidth!/3.0, height: 31.5))
        repostButton.setTitle("  Repost", forState: UIControlState.Normal)
        repostButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        repostButton.titleLabel?.font = UIFont.systemFontOfSize(15, weight: UIFontWeightThin)
        repostButton.setImage(UIImage(named: "repost32"), forState: .Normal)
        repostButton.addTarget(self, action: Selector("repostWeiboStatus:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        let commentButton = UIButton.init(frame: CGRect(x: tableViewCellWidth!/3.0, y: 1, width: tableViewCellWidth!/3.0, height: 31.5))
        commentButton.setTitle("  Comment", forState: .Normal)
        commentButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        commentButton.titleLabel?.font = UIFont.systemFontOfSize(15, weight: UIFontWeightThin)
        commentButton.setImage(UIImage(named: "comment32"), forState: .Normal)
        commentButton.addTarget(self, action: Selector("commentWeiboStatus:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        let likeButton = UIButton.init(frame: CGRect(x: (tableViewCellWidth!/3.0)*2, y: 1, width: tableViewCellWidth!/3.0, height: 31.5))
        likeButton.setTitle("  like", forState: .Normal)
        likeButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        likeButton.titleLabel?.font = UIFont.systemFontOfSize(15, weight: UIFontWeightThin)
        likeButton.setImage(UIImage(named: "like32"), forState: .Normal)
        likeButton.addTarget(self, action: Selector("likeWeiboStatus:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        let separator1 = UIView(frame: CGRect(x: tableViewCellWidth!/3.0, y: 11, width: 1, height: 11))
        separator1.backgroundColor = UIColor.lightGrayColor()
        let separator2 = UIView(frame: CGRect(x: 2.0*tableViewCellWidth!/3.0, y: 11, width: 1, height: 11))
        separator2.backgroundColor = UIColor.lightGrayColor()
        let separator3 = UIView(frame: CGRect(x: 0, y: 32, width: tableViewCellWidth!, height: 10))
        separator3.backgroundColor = UIColor(red: 242/250, green: 242/250, blue: 242/250, alpha: 1)
        let separator4 = UIView(frame: CGRect(x: 0, y: 0, width: tableViewCellWidth!, height: 0.5))
        separator4.backgroundColor = UIColor.lightGrayColor()
        
        repostCommentLikeBarView.addSubview(repostButton)
        repostCommentLikeBarView.addSubview(commentButton)
        repostCommentLikeBarView.addSubview(likeButton)
        repostCommentLikeBarView.addSubview(separator1)
        repostCommentLikeBarView.addSubview(separator2)
        repostCommentLikeBarView.addSubview(separator3)
        repostCommentLikeBarView.addSubview(separator4)
    }
    
    //MARK: - Repost Comment Like Buttons
    func repostWeiboStatus(sender:AnyObject){
        
        let cell = sender.superview!!.superview!.superview as! UITableViewCell
        
        let indexPath = self.tableView!.indexPathForCell(cell)
        
        self.selectedWeiboStatus = self.weiboStatusesArray[(indexPath?.row)!]
        
        let repostViewController = NBWRespotViewController.init(weiboStatus: self.selectedWeiboStatus!)
        
        delegate?.pushViewController(repostViewController)
    }
    
    func commentWeiboStatus(sender:AnyObject){
        
        let cell = sender.superview!!.superview?.superview as! UITableViewCell
        
        let indexPath = self.tableView!.indexPathForCell(cell)
        
        self.selectedWeiboStatus = self.weiboStatusesArray[indexPath!.row]
        
        let contextViewController = NBWeiboContextBasicViewController.init(id: self.selectedWeiboStatus!.id!, tableViewBool: true)
        
        contextViewController.hidesBottomBarWhenPushed = true
        
        delegate?.pushViewController(contextViewController)
    }
    
    func likeWeiboStatus(sender:UIButton){
        likeFlag = !likeFlag
        if likeFlag {
            sender.setImage(UIImage(named: "like32_selected"), forState: .Normal)
        }else {
            sender.setImage(UIImage(named: "like32"), forState: .Normal)
        }
    }

}
