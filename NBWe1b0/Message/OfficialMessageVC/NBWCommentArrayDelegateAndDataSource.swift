//
//  NBWCommentArrayDelegateAndDataSource.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/16/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit
import SDWebImage

class NBWCommentArrayDelegateAndDataSource: NSObject {
    
    var commentArray = [Comment]()
    var cellHeightArray = [CGFloat]()
    var comment:Comment?
    
    //MARK: - Init
    init(comments:[Comment]) {
        super.init()
        commentArray = comments
    }
}

//MARK: - DataSource
extension NBWCommentArrayDelegateAndDataSource:UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        comment = commentArray[indexPath.row]
        
        if comment!.reply_comment != nil {
            let cell = tableView.dequeueReusableCellWithIdentifier("ReplyCommentCell", forIndexPath: indexPath) as! NBWReplyCommentCell
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! NBWCommentCell
            
            return cell
        }
    }
}


//MARK: - Delgate
extension NBWCommentArrayDelegateAndDataSource:UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if cellHeightArray.count ==  commentArray.count {
            return cellHeightArray[indexPath.row]
        }else{
            let comment = commentArray[indexPath.row]
            let textLabelHeight = calculateTextLabelHeight(comment.text!, fontSize: 15, viewWidth: viewWidth! - 16)
            if comment.reply_comment == nil {
                let height = 152 + textLabelHeight
                cellHeightArray.append(height)
                return height
            }else{
                let name = comment.reply_comment?.user?.screen_name
                let text = "@\(name!): \((comment.reply_comment?.text)!)"
                let replyCommentLableHeight = calculateTextLabelHeight(text, fontSize: 15, viewWidth: viewWidth! - 16)
                let height = 168 + textLabelHeight + replyCommentLableHeight
                cellHeightArray.append(height)
                return height
            }
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if comment?.reply_comment != nil {
            configureReplyCommentCell(cell as! NBWReplyCommentCell, comment: comment!)
        }else{
            configureCommentCell(cell as! NBWCommentCell, comment: comment!)
        }
        
        cell.layoutMargins = UIEdgeInsetsZero
        cell.separatorInset = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func configureCommentCell(cell:NBWCommentCell,comment:Comment){
        
        cell.avater.sd_setImageWithURL(NSURL(string: (comment.user?.avatar_large)!))
        cell.avater.clipsToBounds = true
        cell.avater.layer.cornerRadius = 20
        cell.screenNameLabel.text = comment.user?.screen_name
        cell.createdAtLabel.text = createdAtLabelText(comment.created_at!, source: comment.source!)
        cell.commentTextLabel.text = comment.text
        
        let imageURLString = imageURLStringInCommentCell(comment)
        
        cell.weiboStatusImageView.sd_setImageWithURL(NSURL(string: imageURLString))
        
        cell.nameLabel.text = "@\((comment.status?.user?.screen_name)!)"
        
        var context:String?
        if comment.status?.retweeted_status != nil {
            let name = comment.status?.retweeted_status?.user?.screen_name
            let text = comment.status?.retweeted_status?.text
            context = "\((comment.status?.text)!)//@\(name!):\(text!)"
        }else{
            context = comment.status?.text
        }
        
        cell.statusTextLabel.text = context
    }
    
    func configureReplyCommentCell(cell:NBWReplyCommentCell,comment:Comment){
        cell.avater.sd_setImageWithURL(NSURL(string: (comment.user?.avatar_large)!))
        cell.avater.clipsToBounds = true
        cell.avater.layer.cornerRadius = 20
        cell.screenNameLabel.text = comment.user?.screen_name
        cell.createdAtLabel.text = createdAtLabelText(comment.created_at!, source: comment.source!)
        cell.commentTextLabel.text = comment.text
        
        let name = comment.reply_comment?.user?.screen_name
        let text = "@\(name!): \((comment.reply_comment?.text)!)"
        cell.replyNameLabel.text = text
        
        let imageURLString = imageURLStringInCommentCell(comment)
        
        cell.statusImageView.sd_setImageWithURL(NSURL(string: imageURLString))
        cell.nameLabel.text = "@\((comment.status?.user?.screen_name)!)"
        cell.statusTextLabel.text = comment.status?.text
    }
    
    func imageURLStringInCommentCell(comment:Comment)->String {
        var imageURLString:String?
        
        if comment.status?.bmiddle_pic != nil {
            imageURLString = comment.status?.bmiddle_pic
        }else{
            if comment.status?.retweeted_status != nil {
                if comment.status?.retweeted_status?.bmiddle_pic != nil {
                    imageURLString = comment.status?.retweeted_status?.bmiddle_pic
                }else{
                    imageURLString = comment.status?.user?.avatar_large
                }
            }else{
                imageURLString = comment.user?.avatar_large
            }
        }
        return imageURLString!
    }
}
