//
//  NBWBasicTableViewCellFunctions.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/4/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import Foundation
import SDWebImage

func calculateTextLabelHeight(text:String,fontSize:CGFloat,viewWidth:CGFloat)->CGFloat{
    
    let labelText                          = text
    let labelTextNSString                  = NSString(CString:labelText, encoding: NSUTF8StringEncoding)
    let labelFont                          = UIFont.systemFontOfSize(fontSize, weight: UIFontWeightThin)
    let attributesDictionary               = [NSFontAttributeName:labelFont]
    let labelSize                          = CGSize(width: viewWidth-16, height:CGFloat.max)
    let options:NSStringDrawingOptions     = [.UsesLineFragmentOrigin,.UsesFontLeading]
    let labelRect                          = labelTextNSString!.boundingRectWithSize(labelSize, options: options, attributes: attributesDictionary,context: nil)
    
    return labelRect.height
}

func createdAtLabelText(date:NSDate,source:String) -> String{
    
    let dateFormatter = NSDateFormatter.init()
    dateFormatter.dateFormat = "MM-dd HH:mm"
    let dateString    = dateFormatter.stringFromDate(date)

    return "\(dateString) From \(source)"
}

func setupHeaderOfStatusView(view:UIView,_ avaterString:String,_ name:String,_ createdAt:NSDate, _ source:String,_ text:String, _ width:CGFloat){
    
    let avater                      = UIImageView(frame: CGRect(x: 8, y: 8, width: 40, height: 40))
    avater.sd_setImageWithURL(NSURL(string: avaterString))
    
    let screenNameLabel             = UILabel(frame: CGRect(x: 56, y: 8, width: 200, height: 20))
    screenNameLabel.text            = name
    screenNameLabel.font            = UIFont.systemFontOfSize(15)
    
    let createdAtLabel              = UILabel(frame: CGRect(x: 56, y: 32, width: view.frame.width - 64, height: 16))
    createdAtLabel.text             = createdAtLabelText(createdAt, source: source)
    createdAtLabel.font             = UIFont.systemFontOfSize(13, weight: UIFontWeightThin)
    
    let labelHeight                 = calculateTextLabelHeight(text,fontSize: 15,viewWidth: width)
    let textLabel                   = UILabel(frame: CGRect(x: 8, y: 56, width: view.frame.width - 16, height: labelHeight))
    textLabel.text                  = text
    textLabel.numberOfLines         = 0
    textLabel.font                  = UIFont.systemFontOfSize(15, weight: UIFontWeightThin)
    
    view.addSubview(avater)
    view.addSubview(screenNameLabel)
    view.addSubview(createdAtLabel)
    view.addSubview(textLabel)
}

func statusViewInBrief(statusView:UIView,imageURLString:String,name:String,context:String){
    
    let statusImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
    statusView.addSubview(statusImageView)
    statusImageView.sd_setImageWithURL(NSURL(string: imageURLString))
    
    let nameLabel = UILabel(frame: CGRect(x: 88, y: 8, width: 100, height: 18))
    nameLabel.font = UIFont.systemFontOfSize(15)
    nameLabel.text = "@\(name)"
    statusView.addSubview(nameLabel)
    
    let replyCommentTextLabel = UILabel(frame: CGRect(x: 88, y: 30, width: statusView.frame.width - 96, height: 42))
    replyCommentTextLabel.numberOfLines = 0
    replyCommentTextLabel.font = UIFont.systemFontOfSize(13, weight: UIFontWeightThin)
    replyCommentTextLabel.text = context
    replyCommentTextLabel.numberOfLines = 0
    statusView.addSubview(replyCommentTextLabel)
}


//MARK: - HomeTableViewCellHeight
func calculateBasicCell(weiboStatus:WeiboStatus) -> CGFloat{
    
    let headerHeight:CGFloat = 40
    
    let bodyLabelHeight:CGFloat = calculateTextLabelHeight(weiboStatus.text!, fontSize: 17, viewWidth: viewWidth!)
    
    let spacingHeight:CGFloat = 8
    
    let imageHeight:CGFloat = 105
    
    let bottomHeight:CGFloat = 67 // 17 + 8 + 32 + 10
    
    var cellHeight:CGFloat?
    
    if weiboStatus.bmiddle_pic != nil  {
        cellHeight = headerHeight + bodyLabelHeight + imageHeight + spacingHeight * 4 + bottomHeight
    }else{
        cellHeight = headerHeight + bodyLabelHeight  + spacingHeight * 3 + bottomHeight
    }
    
    return cellHeight!
}

func calculateImageCell(weiboStatus:WeiboStatus) -> CGFloat{
    
    let headerHeight:CGFloat = 40
    
    let bodyLabelHeight:CGFloat = calculateTextLabelHeight(weiboStatus.text!, fontSize: 17, viewWidth: viewWidth!)
    
    let spacingHeight:CGFloat = 8
    
    let imageHeight:CGFloat = (viewWidth! - 32)/3
    
    let bottomHeight:CGFloat = 32 + 10 + 25
    
    var cellHeight = headerHeight + bodyLabelHeight + imageHeight + spacingHeight * 3 + bottomHeight + 12
    
    if weiboStatus.pics?.count > 3 {
        cellHeight += imageHeight
    }
    
    return cellHeight
}

func calculateRepostCellHeight(weiboStatus:WeiboStatus) -> CGFloat{
    
    let headerHeight:CGFloat = 48
    
    let bodyLabelHeight:CGFloat = calculateTextLabelHeight(weiboStatus.text!, fontSize: 17, viewWidth: viewWidth!) + 8
    
    let repostText = "@\((weiboStatus.retweeted_status?.user?.screen_name)!):\((weiboStatus.retweeted_status?.text)!)"
    let repostTextLabelHeight:CGFloat = calculateTextLabelHeight(repostText, fontSize: 17, viewWidth: viewWidth!) + 8
    
    let singleImageHeight:CGFloat = (viewWidth! - 32)/3
    
    var imageHeight:CGFloat?
    if weiboStatus.retweeted_status?.pics?.count > 3 {
        imageHeight = (singleImageHeight) * 2 + 16
    }else if weiboStatus.retweeted_status?.bmiddle_pic == nil {
        imageHeight = 0
    }else{
        imageHeight = (singleImageHeight) + 8
    }
    
    let repostHeight:CGFloat = 8 + repostTextLabelHeight +  imageHeight! + 8
    
    let bottomHeight:CGFloat = 75 // 8 + 17 + 8 + 42
    
    let cellHeight = headerHeight + bodyLabelHeight + repostHeight + bottomHeight

    return cellHeight
}
