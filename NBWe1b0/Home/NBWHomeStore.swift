//
//  NBWHomeStore.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/17/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class NBWHomeStore: NSObject {
    
    var weiboStatusesArray = [WeiboStatus]()
    var weiboStatus:WeiboStatus?
    var delegate:FetchDataFromStoreDelegate?
    
    init(urlString:String) {
        super.init()
//        timelineFetchDataFromWeibo(urlString)
        fetchDataFromHomeTimeLine(urlString)
    }
    
    //MARK: - FetchData
    //FromWeb
    func fetchDataFromHomeTimeLine(urlString:String){
        
        let downloadStatusGroup = dispatch_group_create()
        
        dispatch_group_enter(downloadStatusGroup)
        
        Alamofire.request(.GET, urlString, parameters: ["access_token":accessToken,"count":20], encoding: ParameterEncoding.URL, headers: nil)
            .responseJSON { (response) -> Void in
                
                do {
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(response.data!, options: .AllowFragments) as! NSDictionary
                    let statusesArrary = jsonDictionary.valueForKey("statuses") as! NSArray
                    
                    self.weiboStatusPesistentlyStoreInCoreData(statusesArrary)
                    
                }catch let error as NSError{
                    print("Error:\(error.localizedDescription)")
                }
                dispatch_group_leave(downloadStatusGroup)
        }
        
        dispatch_group_notify(downloadStatusGroup, dispatch_get_main_queue()) { 
            self.fetchDataFromCoreData()
        }

    }
    
//    func timelineFetchDataFromWeibo(urlString:String){
//    
//        Alamofire.request(.GET, urlString, parameters: ["access_token":accessToken,"count":20], encoding: ParameterEncoding.URL, headers: nil)
//            .responseJSON { (response) -> Void in
//                
//                do {
//                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(response.data!, options: .AllowFragments) as! NSDictionary
//                    let statusesArrary = jsonDictionary.valueForKey("statuses") as! NSArray
//                    
//                    self.weiboStatusPesistentlyStoreInCoreData(statusesArrary)
//                    
//                }catch let error as NSError{
//                    print("Error:\(error.localizedDescription)")
//                }
//    
//        }
//    }
    
    //FromCoreData
    func fetchDataFromCoreData(){
        
        do{
            let request = NSFetchRequest(entityName: "WeiboStatus")
            weiboStatusesArray = try managerContext!.executeFetchRequest(request) as! [WeiboStatus]
        }catch let error as NSError {
            print("Fetching error: \(error.localizedDescription)")
        }
        
        weiboStatusesArray = weiboStatusesArray.sort({ (status1, status2) -> Bool in
        if (status1.created_at?.compare(status2.created_at!) == NSComparisonResult.OrderedDescending){
                return true
        }else{
                return false
        }
    })
        
        self.delegate?.fetchDataFromWeb(weiboStatusesArray)
    }
    
    func fetchOneWeiboStatusFromCoreDate(id:String)->Bool {
        
        let request = NSFetchRequest(entityName: "WeiboStatus")
        request.predicate = NSPredicate(format: "id == \(id)")
        
        do{
            let array =  try managerContext?.executeFetchRequest(request) as! [WeiboStatus]
            if array.count != 0 {
                weiboStatus = array[0]
                return true
            }
        }catch let error as NSError {
            print("Fetch Error: \(error.localizedDescription)")
        }
        
        return false
    }
    
    //MARK: - StoreData
    func weiboStatusPesistentlyStoreInCoreData(statuesArray:NSArray){

        for jsonDict in statuesArray {
            
            let id = jsonDict["idstr"] as? String
            
            if !weiboStatusAlreadyExisted(id!) {
                
                //create NSManagedObject
                let weiboUser            = weiboUserManagedObject()
                
                let weiboStatus          = weiboStatusManagedObject()
                
                importStatusDataFromJSON(weiboStatus, jsonDict: jsonDict as! NSDictionary)
                weiboStatus.user         = weiboUser
                
                //retweeted_status
                let retweeted_statusDict = jsonDict["retweeted_status"] as? NSDictionary
                
                if retweeted_statusDict == nil{
                    weiboStatus.retweeted_status = nil
                }else{
                    let retweetedStatus          = weiboStatusManagedObject()
                    let retweedtedUser           = weiboUserManagedObject()
                    
                    importStatusDataFromJSON(retweetedStatus, jsonDict: retweeted_statusDict!)
                    
                    weiboStatus.retweeted_status = retweetedStatus
                    
                    let retweetedUserDict        = retweeted_statusDict!["user"] as! NSDictionary
                    
                    importUserDataFromJSON(retweedtedUser, userDict: retweetedUserDict)
                    retweedtedUser.status        = retweedtedUser.status?.setByAddingObject(retweetedStatus)
                }
                
                //user
                let userDict = jsonDict["user"] as! NSDictionary
                
                importUserDataFromJSON(weiboUser, userDict: userDict)
                
                weiboUser.status = weiboUser.status?.setByAddingObject(weiboStatus)
                
            }
        }

        managerContextSave()
    }
}
