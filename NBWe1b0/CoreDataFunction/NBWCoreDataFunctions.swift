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

var weiboStatusesArray = [WeiboStatus]()

func weiboStatusPesistentlyStoreInCoreData(statuesArray:NSArray){
    
    fetchWeiboStatusDataFromCoreData()
    
    
    
}


//MARK: Fetch data frome core data
//WeiboStatus
func fetchWeiboStatusDataFromCoreData(){
    
    do{
        let request = NSFetchRequest(entityName: "WeiboStatus")
        weiboStatusesArray = try managerContext!.executeFetchRequest(request) as! [WeiboStatus]
    }catch let error as NSError {
        print("Fetching error: \(error.localizedDescription)")
    }
}

//WeiboUser


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

