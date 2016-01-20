//
//  NBWHomeViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 1/11/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import MJExtension
import MJRefresh
import SDWebImage

class NBWHomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let homeTimeline     = "https://api.weibo.com/2/statuses/home_timeline.json"
    let resuseIdentifier = "BasicCell"
    
    var refreshController:UIRefreshControl?
    var cellCache:NSCache?
    var numberOfImageRow:CGFloat?
    var weiboStatusesArray = [WeiboStatus]()
    var managerContext:NSManagedObjectContext?
    var searchController:UISearchController?
    var hasImage:Bool?
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        self.tableView.dataSource = self
        self.tableView.delegate   = self
        
        cellCache = NSCache.init()
        
        setUpRefresh()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.managerContext = appDelegate.managedObjectContext
    }
    
    func setUpRefresh(){
        
        self.refreshController = UIRefreshControl.init()
        self.tableView.addSubview(self.refreshController!)
        self.refreshController?.tintColor = UIColor.orangeColor()
        let attributedStrDict = [NSForegroundColorAttributeName:UIColor.orangeColor()]
        self.refreshController?.attributedTitle = NSAttributedString.init(string: "Refresh Data", attributes: attributedStrDict)
        
        self.refreshController!.addTarget(self, action: Selector(homeTimelineFetchDataFromWeibo()), forControlEvents: UIControlEvents.ValueChanged)

        self.refreshController!.beginRefreshing()
        
        self.homeTimelineFetchDataFromWeibo()
    }
    
    @IBAction func weiboLogin(sender: UIBarButtonItem) {
        let request         = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = redirectURL
        request.scope       = "all"
        
        WeiboSDK.sendRequest(request)
    }
    
    
    //MARK: - Weibo.com
    func homeTimelineFetchDataFromWeibo(){
        
        Alamofire.request(.GET, homeTimeline, parameters: ["access_token":accessToken,"count":10], encoding: ParameterEncoding.URL, headers: nil)
            .responseJSON { (response) -> Void in
                
                do {
                   let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(response.data!, options: .AllowFragments) as! NSDictionary
                    let statusesArrary = jsonDictionary.valueForKey("statuses") as! NSArray
                    
                    self.importJSONInCoreData(statusesArrary)
                    
                }catch let error as NSError{
                    print("Error:\(error.localizedDescription)")
                }
                self.refreshController?.endRefreshing()
        }
    }
    
    
    
    //MARK: - CoreData
    func importJSONInCoreData(statuesArray:NSArray){
    
        // weibo status is stored in WeiboStatus from CoreData
        weiboStatusPesistentlyStoreInCoreData(statuesArray)
        
        do{
            try self.managerContext!.save()
        }catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        fetchDataFromCoreData()
        
        self.tableView.reloadData()
    }
    
    func weiboStatusPesistentlyStoreInCoreData(statuesArray:NSArray){
        
        for jsonDict in statuesArray {
            
            //compare idstr
            var flag = true
            for status in weiboStatusesArray {
                let id = jsonDict["idstr"] as? String
                if id == status.id {
                    flag = false
                }
            }
            
            if flag == true {
                //create NSManagedObject
                let weiboStatusEntity = NSEntityDescription.entityForName("WeiboStatus", inManagedObjectContext: managerContext!)

                let userEntity        = NSEntityDescription.entityForName("WeiboUser", inManagedObjectContext: managerContext!)

                let picEntity         = NSEntityDescription.entityForName("WeiboStatusPics", inManagedObjectContext: managerContext!)

                let weiboUser         = NSManagedObject(entity: userEntity!, insertIntoManagedObjectContext: managerContext) as! WeiboUser

                let weiboStatus       = NSManagedObject(entity: weiboStatusEntity!, insertIntoManagedObjectContext:managerContext) as! WeiboStatus

                //pic_urls
                let dictArray         = jsonDict["pic_urls"] as? Array<[String:String]>
                let pic_urlsArray     = picUrlsJSONToString(dictArray!)
                
                if pic_urlsArray.count > 0 {
                    for pic_url in pic_urlsArray {
                        let weiboStatusPic    = NSManagedObject(entity: picEntity!, insertIntoManagedObjectContext: managerContext) as! WeiboStatusPics
                        weiboStatusPic.pic    = pic_url.thumbnail_pic
                        weiboStatusPic.status = weiboStatus
                        weiboStatus.pics      = weiboStatus.pics?.setByAddingObject(weiboStatusPic)
                    }
                }
                
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
                weiboStatus.user            = weiboUser
                
                
                //user
                let userDict = jsonDict["user"] as! NSDictionary
                
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
                weiboUser.status             = weiboUser.status?.setByAddingObject(weiboStatus)
            }
        }
    }
    
    func fetchDataFromCoreData(){
        
        do{
            let request = NSFetchRequest(entityName: "WeiboStatus")
            weiboStatusesArray = try managerContext!.executeFetchRequest(request) as! [WeiboStatus]
        }catch let error as NSError {
            print("Fetching error: \(error.localizedDescription)")
        }
    }
    
    //MARK: - AssitedFunction
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

        return picURLs
    }
}


    //MARK: - UITableViewDataSource

extension NBWHomeViewController: UITableViewDataSource,  UITableViewDelegate, UINavigationBarDelegate{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        weiboStatusesArray = weiboStatusesArray.sort({ (status1, status2) -> Bool in
            if (status1.created_at?.compare(status2.created_at!) == NSComparisonResult.OrderedDescending){
                return true
            }else{
                return false
            }
        })

        return weiboStatusesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let key:String = "\(indexPath.section)-\(indexPath.row)"
        
        var cell = self.cellCache?.objectForKey(key) as? NBWTableViewBasicCell
        
        if cell == nil {
            cell = tableView.dequeueReusableCellWithIdentifier(resuseIdentifier) as? NBWTableViewBasicCell
            configureHomeTableViewCell(cell!,indexPath: indexPath)
        }else {
            configureHomeTableViewCell(cell!,indexPath: indexPath)
        }
        
        self.cellCache?.setObject(cell!, forKey: key)

        return cell!
    }
    
    //HeightForRow
//    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if numberOfImageRow > 0 {
//            return 240.0
//        }else{
//            return 150.0
//        }
//    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let key:String = "\(indexPath.section)-\(indexPath.row)"
        
        var cell = self.cellCache?.objectForKey(key) as?NBWTableViewBasicCell
        
        if cell == nil {
            cell = tableView.dequeueReusableCellWithIdentifier(resuseIdentifier) as? NBWTableViewBasicCell
            configureHomeTableViewCell(cell!, indexPath: indexPath)
            self.cellCache?.setObject(cell!, forKey: key)
        }
        
        let headerHeight:CGFloat = 40
        
        let bodyLabelHeight:CGFloat = (cell?.bodyTextLabel.frame.height)!
        
        let spacingHeight:CGFloat = 8
        
        let imageHeight:CGFloat = 200
        
        let bottomHeight:CGFloat = 32 + 8
        
        var cellHeight:CGFloat?
        if hasImage == true  {
           cellHeight = headerHeight + bodyLabelHeight + imageHeight + spacingHeight * 3 + bottomHeight + 16
        }else{
           cellHeight = headerHeight + bodyLabelHeight  + spacingHeight * 3 + bottomHeight + 16
        }
        
        print("The Height of Cell is: \(cellHeight)\n bodyLabelHeigt:\(bodyLabelHeight)\n imageHeight:\(imageHeight)")
        
        return cellHeight!
    }
    
    //The Background of selected Cell disappear
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func configureHomeTableViewCell(cell:NBWTableViewBasicCell,indexPath:NSIndexPath)-> NBWTableViewBasicCell {
        
        let weiboStatus = weiboStatusesArray[indexPath.row]
        
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
        let labelSize                      = CGSize(width: self.tableView.frame.width-16, height:CGFloat.max)
        let options:NSStringDrawingOptions = [.UsesLineFragmentOrigin,.UsesFontLeading]

        let labelRect                      = labelTextNSString!.boundingRectWithSize(labelSize, options: options, attributes: attributesDictionary,context: nil)

        cell.bodyTextLabel.frame           = labelRect
        
        //Setup ImageStackView
        configureImageView(cell,weiboStatus: weiboStatus)

        //Setup bottomView
//        cell.repostCount.text  = "\(weiboStatus.reposts_count!)"
//        cell.commentCount.text = "\(weiboStatus.comments_count!)"
//        cell.likeCout.text     = "\(weiboStatus.attitudes_count!)"
        
        return cell
    }

    func configureImageView(cell:NBWTableViewBasicCell,weiboStatus:WeiboStatus){
        
//        let imageViewArray = [cell.imageViewOne,cell.imageViewTwo,cell.imageViewThree,cell.imageViewFour,cell.imageViewFive,cell.imageViewSix,cell.imageViewSeven,cell.imageViewEight,cell.imageViewNine]
//        
//        let weiboStatusSet = weiboStatus.pics as! Set<WeiboStatusPics>
//
//        let picsCount      = weiboStatusSet.count
//        
//        if picsCount == 1 || picsCount == 2 || picsCount == 3{
//            
//            numberOfImageRow = 1
//            var picsCount = 0
//            for weiboStatusPic in  weiboStatusSet {
//                imageViewArray[picsCount].sd_setImageWithURL(NSURL(string:weiboStatusPic.pic!))
//                    picsCount += 1
//            }
//            
//            
//            for var i = 3; i < 9; i = i+1 {
//               imageViewArray[i].removeFromSuperview()
//            }
//            
//        }else if picsCount == 4 || picsCount == 5 || picsCount == 6 {
//            
//            numberOfImageRow = 2
//            var picsCount = 0
//            for weiboStatusPic in  weiboStatusSet {
//                imageViewArray[picsCount].sd_setImageWithURL(NSURL(string:weiboStatusPic.pic!))
//                picsCount += 1
//            }
//            
//            for var i = 6; i < 9; i = i+1 {
//                imageViewArray[i].removeFromSuperview()
//            }
//            
//        }else if picsCount == 7 || picsCount == 8 || picsCount == 9 {
//            
//            numberOfImageRow = 3
//            var picsCount = 0
//            for weiboStatusPic in  weiboStatusSet {
//                imageViewArray[picsCount].sd_setImageWithURL(NSURL(string:weiboStatusPic.pic!))
//                picsCount += 1
//            }
//        
//        }else {
//            numberOfImageRow = 0
//            for var i = 0; i < 9; i = i+1 {
//                imageViewArray[i].removeFromSuperview()
//            }
//        }
        
        if (weiboStatus.bmiddle_pic != nil) {
            cell.imageViewOne.sd_setImageWithURL(NSURL(string: weiboStatus.bmiddle_pic!))
            self.hasImage = true
        }else{
            cell.imageViewOne.removeFromSuperview()
            self.hasImage = false
        }
    }
}
