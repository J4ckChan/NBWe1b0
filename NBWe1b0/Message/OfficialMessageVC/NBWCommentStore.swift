//
//  NBWCommentStore.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/16/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

protocol FetchDataFromStoreDelegate{
    func fetchDataFromWeb(array:[AnyObject])
}

class NBWCommentStore: NSObject {
    
    var commentArray = [Comment]()
    var comment:Comment?
    var delegate:FetchDataFromStoreDelegate?
    
    init(urlString:String,filterByAuthor:Int){
        super.init()
        fetchCommentDataFromWeibo(urlString, filterByAuthor)
    }
    
    //MARK: - FetchData
    
    func fetchCommentDataFromWeibo(urlString:String,_ filterByAuthor:Int){
        
        Alamofire.request(.GET, urlString, parameters: ["access_token":accessToken,"count":20,"filter_by_author":filterByAuthor], encoding: ParameterEncoding.URL, headers: nil)
            .responseJSON { (Response) -> Void in
                
                do {
                    let dict =  try NSJSONSerialization.JSONObjectWithData(Response.data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                    let array = dict["comments"] as! NSArray
                    
                    self.commentIntoCoreData(array)
                    
                }catch let error as NSError{
                    print("Fetch error:\(error.localizedDescription)")
                }
        }
    }
    
    func fetchDataFromCoreData()->[Comment]{
        
        let request = NSFetchRequest(entityName: "Comment")
        var array:[Comment]?
        
        do{
            array = try managerContext?.executeFetchRequest(request) as? [Comment]
        }catch let error as NSError{
            print("Fetch comment error:\(error.localizedDescription)")
        }
        
        array?.sortInPlace({ (comment1, comment2) -> Bool in
            if comment1.created_at?.compare(comment2.created_at!) == NSComparisonResult.OrderedDescending {
                return true
            }else{
                return false
            }
        })
        
        return array!
    }

    
    //MARK: - StoreData
    func commentIntoCoreData(array:NSArray){
        
        commentArray = []
        
        for commentDict in array {
            
            let idstr = commentDict["idstr"] as? String
            
            if commentAlreadyExisted(idstr!) {
                commentArray.append(comment!)
            }else{
                let comment             = weiboCommentManagedObject()
                importCommentDataFromJSON(comment, commentDict: commentDict as! NSDictionary)
                
                let weiboUser           = weiboUserManagedObject()
                let weiboUserDict       = commentDict["user"] as! NSDictionary
                importUserDataFromJSON(weiboUser, userDict: weiboUserDict)
                comment.user            = weiboUser
                
                let weiboStatus         = weiboStatusManagedObject()
                let weiboStatusDict     = commentDict["status"] as! NSDictionary
                importStatusDataFromJSON(weiboStatus, jsonDict: weiboStatusDict)
                comment.status          = weiboStatus
                
                let weiboStatusUser     = weiboUserManagedObject()
                let weiboStatusUserDict = weiboStatusDict["user"] as! NSDictionary
                importUserDataFromJSON(weiboStatusUser, userDict: weiboStatusUserDict)
                comment.status?.user    = weiboStatusUser
                
                let retweetedStatusDict = weiboStatusDict["retweeted_status"] as? NSDictionary
                
                if retweetedStatusDict == nil {
                    comment.status?.retweeted_status = nil
                }else{
                    let retweetedStatus = weiboStatusManagedObject()
                    importStatusDataFromJSON(retweetedStatus, jsonDict: retweetedStatusDict!)
                    comment.status?.retweeted_status = retweetedStatus
                    
                    let retweetedUser = weiboUserManagedObject()
                    let retweetedUserDict = retweetedStatusDict!["user"] as! NSDictionary
                    importUserDataFromJSON(retweetedUser, userDict: retweetedUserDict)
                    comment.status?.retweeted_status?.user = retweetedUser
                }
                
                let reply_commentDict = commentDict["reply_comment"] as? NSDictionary
                
                if reply_commentDict == nil {
                    comment.reply_comment = nil
                }else{
                    let replyComment            = weiboCommentManagedObject()
                    importCommentDataFromJSON(replyComment, commentDict: reply_commentDict!)
                    comment.reply_comment       = replyComment
                    
                    let replyCommentUser        = weiboUserManagedObject()
                    let replyCommentUserDict    = reply_commentDict!["user"] as! NSDictionary
                    importUserDataFromJSON(replyCommentUser, userDict: replyCommentUserDict)
                    comment.reply_comment?.user = replyCommentUser
                }
                commentArray.append(comment)
            }
        }
        
        delegate?.fetchDataFromWeb(commentArray)
        
        managerContextSave()
    }
    
    
    //MARK: - Check Data
    func commentAlreadyExisted(id:String)->Bool{
        
        let request = NSFetchRequest(entityName: "Comment")
        request.predicate = NSPredicate(format: "idstr == \(id)")
        
        do{
            let array = try managerContext?.executeFetchRequest(request) as! [Comment]
            if array.count != 0 {
                comment = array[0]
                return true
            }
        }catch let error as NSError {
            print("Fetch comment error:\(error.localizedDescription)")
        }
        return false
    }
    
}
