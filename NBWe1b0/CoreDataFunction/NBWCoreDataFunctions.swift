//
//  NBWCoreDataFunctions.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/1/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import Foundation
import CoreData
import MJExtension


//MARK: Fetch data frome core data

func weiboStatusAlreadyExisted(id:String)->Bool {
    
    let request = NSFetchRequest(entityName: "WeiboStatus")
    request.predicate = NSPredicate(format: "id == \(id)")
    
    do{
        let array =  try managerContext?.executeFetchRequest(request) as! [WeiboStatus]
        if array.count == 0 {
            return false
        }else{
            return true
        }
    }catch let error as NSError {
        print("Fetch Error: \(error.localizedDescription)")
    }
    
    return false
}

func commentAlreadyExisted(id:String)->Bool{
    
    let request = NSFetchRequest(entityName: "Comment")
    request.predicate = NSPredicate(format: "idstr == \(id)")
    
    do{
        let array = try managerContext?.executeFetchRequest(request) as! [Comment]
        if array.count == 0 {
            return false
        }else{
            return true
        }
    }catch let error as NSError {
        print("Fetch comment error:\(error.localizedDescription)")
    }
    return false
}

//MARK: - Pesistently Store in CoreData

//MARK: NSManagedObject
func weiboStatusManagedObject()->WeiboStatus{
    
    let weiboStatusEntity = NSEntityDescription.entityForName("WeiboStatus", inManagedObjectContext: managerContext!)
    let weiboStatus       = NSManagedObject(entity: weiboStatusEntity!, insertIntoManagedObjectContext:managerContext) as! WeiboStatus
    
    return weiboStatus
}

func weiboUserManagedObject()->WeiboUser{
    let userEntity        = NSEntityDescription.entityForName("WeiboUser", inManagedObjectContext: managerContext!)
    let weiboUser         = NSManagedObject(entity: userEntity!, insertIntoManagedObjectContext: managerContext) as! WeiboUser
    
    return weiboUser
}

func weiboCommentManagedObject()->Comment{
    let commentEntity = NSEntityDescription.entityForName("Comment", inManagedObjectContext: managerContext!)
    let comment = NSManagedObject(entity: commentEntity!, insertIntoManagedObjectContext: managerContext!) as! Comment
    
    return comment
}


//MARK: WeiboStatus
func importStatusDataFromJSON(weiboStatus:WeiboStatus,jsonDict:NSDictionary){
    //status
    weiboStatus.created_at      = createdAtDateStringToNSDate((jsonDict["created_at"] as? String)!)
    weiboStatus.id              = jsonDict["idstr"] as? String
    weiboStatus.text            = jsonDict["text"] as? String
    weiboStatus.source          = sourceStringModifiedWithString((jsonDict["source"] as? String)!)
    weiboStatus.favorited       = jsonDict["favorited"] as? NSNumber
    weiboStatus.reposts_count   = jsonDict["reposts_count"] as? NSNumber
    weiboStatus.comments_count  = jsonDict["comments_count"] as? NSNumber
    weiboStatus.attitudes_count = jsonDict["attitudes_count"] as? NSNumber
    weiboStatus.thumbnail_pic   = jsonDict["thumbnail_pic"] as? String
    weiboStatus.bmiddle_pic     = jsonDict["bmiddle_pic"] as? String
    weiboStatus.original_pic    = jsonDict["original_pic"] as? String
    
    //pic_urls
    let dictArray         = jsonDict["pic_urls"] as? Array<[String:String]>
    let pic_urlsArray     = picUrlsJSONToString(dictArray!)
    
    if pic_urlsArray.count > 0 {
        for pic_url in pic_urlsArray {
            
            let picEntity         = NSEntityDescription.entityForName("WeiboStatusPics", inManagedObjectContext: managerContext!)
            let weiboStatusPic    = NSManagedObject(entity: picEntity!, insertIntoManagedObjectContext: managerContext) as! WeiboStatusPics
            
            weiboStatusPic.pic    = pic_url.thumbnail_pic
            weiboStatusPic.status = weiboStatus
            weiboStatus.pics      = weiboStatus.pics?.setByAddingObject(weiboStatusPic)
        }
    }
}

//MARK: WeiboUser
func importUserDataFromJSON(weiboUser:WeiboUser,userDict:NSDictionary){
    
    weiboUser.id                 = userDict["id"] as? NSNumber
    weiboUser.idstr              = userDict["idstr"] as? String
    weiboUser.screen_name        = userDict["screen_name"] as? String
    weiboUser.name               = userDict["name"] as? String
    weiboUser.province           = userDict["province"] as? NSNumber
    weiboUser.city               = userDict["city"] as? NSNumber
    weiboUser.location           = userDict["location"] as? String
    weiboUser.user_description   = userDict["description"] as? String
    weiboUser.url                = userDict["url"] as? String
    weiboUser.profile_image_url  = userDict["profile_image_url"] as? String
    weiboUser.profile_url        = userDict["profile_url"] as? String
    weiboUser.domain             = userDict["domain"] as? String
    weiboUser.weihao             = userDict["weihao"] as? String
    weiboUser.gender             = userDict["gender"] as? String
    weiboUser.followers_count    = userDict["followers_count"] as? NSNumber
    weiboUser.friends_count      = userDict["friends_count"] as? NSNumber
    weiboUser.statuses_count     = userDict["statuses_count"] as? NSNumber
    weiboUser.favourites_count   = userDict["favourites_count"] as? NSNumber
    weiboUser.created_at         = userDict["created_at"] as? String
    weiboUser.following          = userDict["following"] as? NSNumber
    weiboUser.allow_all_act_msg  = userDict["allow_all_act_msg"] as? NSNumber
    weiboUser.geo_enabled        = userDict["geo_enabled"] as? NSNumber
    weiboUser.verified           = userDict["verified"] as? NSNumber
    weiboUser.verified_type      = userDict["verified_type"] as? NSNumber
    weiboUser.remark             = userDict["remark"] as? String
    weiboUser.allow_all_comment  = userDict["allow_all_comment"] as? NSNumber
    weiboUser.avatar_large       = userDict["avatar_large"] as? String
    weiboUser.avatar_hd          = userDict["avatar_hd"] as? String
    weiboUser.verified_reason    = userDict["verified_reason"] as? String
    weiboUser.follow_me          = userDict["follow_me"] as? NSNumber
    weiboUser.online_status      = userDict["online_status"] as? NSNumber
    weiboUser.bi_followers_count = userDict["bi_followers_count"] as? NSNumber
    weiboUser.lang               = userDict["lang"] as? String
}

func importCommentDataFromJSON(comment:Comment,commentDict:NSDictionary){
    
    comment.created_at = createdAtDateStringToNSDate(commentDict["created_at"] as? String)
    comment.id         = commentDict["id"] as? NSNumber
    comment.text       = commentDict["text"] as? String
    comment.source     = sourceStringModifiedWithString((commentDict["source"] as? String)!)
    comment.mid        = commentDict["mid"] as? String
    comment.idstr      = commentDict["idstr"] as? String
}

//MARK: - ManagerContextSave
func managerContextSave(){
    do{
        try managerContext!.save()
    }catch let error as NSError {
        print("Error: \(error.localizedDescription)")
    }
}

//MARK: - AssitedFunction
//String to NSData
func createdAtDateStringToNSDate(created_at:String?)->NSDate{
    
    // created_at:Tue Jan 19 09:35:19 +0800 2016
    let dateFormatter = NSDateFormatter()
    let locale = NSLocale(localeIdentifier: "en_US")
    dateFormatter.locale = locale
    dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
    let date = dateFormatter.dateFromString(created_at!)
    
    return date!
}

func sourceStringModifiedWithString(source:String)->String {
    
    if source.characters.count > 0 {
        let locationStart = source.rangeOfString(">")?.endIndex
        let locationEnd = source.rangeOfString("</")?.startIndex
        let sourceName = source.substringWithRange(Range(start: locationStart!,end: locationEnd!))
        
        return sourceName
    }else{
        return "Unknown sources"
    }
}

func picUrlsJSONToString(dictArray:Array<[String:String]>) -> Array<NBWPics>{
    
    let picURLs = NBWPics.mj_objectArrayWithKeyValuesArray(dictArray) as! Array<NBWPics>
    
    for picURL in picURLs {
        picURL.thumbnail_pic = picURL.thumbnail_pic?.stringByReplacingOccurrencesOfString("thumbnail", withString: "bmiddle")
    }
    
    return picURLs
}

