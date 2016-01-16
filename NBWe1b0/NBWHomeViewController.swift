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

class NBWHomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let homeTimeline     = "https://api.weibo.com/2/statuses/home_timeline.json"
    let resuseIdentifier = "BasicCell"
    
    var cellCache:NSCache?
    var numberOfImageStackView:CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        self.tableView.dataSource = self
        self.tableView.delegate   = self
        
        cellCache = NSCache.init()
        
        numberOfImageStackView = 2
        
        getHomeTimeline()
    }
    
    func getHomeTimeline(){
        
        Alamofire.request(.GET, homeTimeline, parameters: ["access_token":accessToken,"count":1], encoding: ParameterEncoding.URL, headers: nil)
            .responseJSON { (response) -> Void in
                
                do {
                   let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(response.data!, options: .AllowFragments) as! NSDictionary
                    let statusesArrary = jsonDictionary.valueForKey("statuses") as! NSArray
                    
                    print(statusesArrary)
                    
                    self.importJSONInCoreData(statusesArrary)
                    
                }catch let error as NSError{
                    print("Error:\(error.localizedDescription)")
                }
        }
    }
    
    @IBAction func weiboLogin(sender: UIBarButtonItem) {
        let request         = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = redirectURL
        request.scope       = "all"
        
        WeiboSDK.sendRequest(request)
    }
    
    //MARK: - CoreData
    func importJSONInCoreData(statuesArray:NSArray){
       
        //init CoreData
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managerContext = appDelegate.managedObjectContext
        
        let weiboStatusEntity = NSEntityDescription.entityForName("WeiboStatus", inManagedObjectContext: managerContext)
        
        let userEntity = NSEntityDescription.entityForName("WeiboUser", inManagedObjectContext: managerContext)
        
        let weiboUser = NSManagedObject(entity: userEntity!, insertIntoManagedObjectContext: managerContext) as! WeiboUser
        
        let weiboStatus = NSManagedObject(entity: weiboStatusEntity!, insertIntoManagedObjectContext:managerContext) as! WeiboStatus
        
        // weibo status is stored in WeiboStatus from CoreData
        weiboStatusPesistentlyStoreInCoreData(weiboUser,weibostatus: weiboStatus,statuesArray: statuesArray)
        
        do{
            try managerContext.save()
        }catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func weiboStatusPesistentlyStoreInCoreData(weiboUser:WeiboUser,weibostatus:WeiboStatus,statuesArray:NSArray){
        
        for jsonDict in statuesArray {
            
            // imageurl 变成 UIImage
            weibostatus.created_at      = jsonDict["created_at"] as? String
            weibostatus.id              = jsonDict["idstr"] as? String
            weibostatus.text            = jsonDict["text"] as? String// text 转化成中文
            weibostatus.source          = jsonDict["source"] as? String
            weibostatus.favorited       = jsonDict["favorited"] as? NSNumber
            weibostatus.reposts_count   = jsonDict["reposts_count"] as? NSNumber
            weibostatus.comments_count  = jsonDict["comments_count"] as? NSNumber
            weibostatus.attitudes_count = jsonDict["attitudes_count"] as? NSNumber
            weibostatus.thumbnail_pic   = jsonDict["thumbnail_pic"] as? String
            weibostatus.bmiddle_pic     = jsonDict["bmiddle_pic"] as? String
            weibostatus.original_pic    = jsonDict["original_pic"] as? String
            weibostatus.user            = weiboUser
            
            let userDict = jsonDict["user"] as! NSDictionary

            weiboUser.id                 = userDict["id"] as? NSNumber
            weiboUser.idstr              = userDict["idstr"] as? String
            weiboUser.screen_name        = userDict["screen_name"] as? String
            weiboUser.name               = userDict["name"] as? String
            weiboUser.province           = userDict["province"] as? NSNumber
            weiboUser.city               = userDict["city"] as? NSNumber
            weiboUser.location           = userDict["location"] as? String// 转换成 中文
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
            weiboUser.status?.setByAddingObject(weibostatus)
        }
    }
}


    //MARK: - UITableViewDataSource

extension NBWHomeViewController: UITableViewDataSource,  UITableViewDelegate, UINavigationBarDelegate{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let key:String = "\(indexPath.section)-\(indexPath.row)"
        
        var cell = self.cellCache?.objectForKey(key) as? NBWTableViewBasicCell
        
        if cell == nil {
            cell = tableView.dequeueReusableCellWithIdentifier(resuseIdentifier) as? NBWTableViewBasicCell
            configureHomeTableViewCell(cell!)
        }else {
            configureHomeTableViewCell(cell!)
        }
        
        
        return cell!
    }
    
    //HeightForRow
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if numberOfImageStackView > 0 {
            return 330.0
        }else{
            return 100.0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let key:String = "\(indexPath.section)-\(indexPath.row)"
        
        var cell = self.cellCache?.objectForKey(key) as?NBWTableViewBasicCell
        
        if cell == nil {
            cell = tableView.dequeueReusableCellWithIdentifier("BasicCell") as? NBWTableViewBasicCell
            cell = configureHomeTableViewCell(cell!)
            cellCache?.setObject(cell!, forKey: key)
        }
        
        let headerHeight:CGFloat = 40
        
        let bodyLabelHeight:CGFloat = (cell?.bodyTextLabel.frame.height)!
        
        let imageHeight:CGFloat = ((self.tableView.frame.width/3.0)-12)*numberOfImageStackView!
        
        let spacingHeight:CGFloat = 8
        
        let cellHeight = headerHeight + bodyLabelHeight + imageHeight + spacingHeight * 3 + 22+32
        
        print("The Height of Cell is: \(cellHeight)\n bodyLabelHeigt:\(bodyLabelHeight)\n imageHeight:\(imageHeight)")
        print(cell?.imageStackView.frame.height)
        
        return cellHeight
    }
    
    func configureHomeTableViewCell(cell:NBWTableViewBasicCell)-> NBWTableViewBasicCell {
        
        //Setup Header
        
        //Setup bodyTextLabel
        let text = "NSCache 一言蔽之是一个很傻瓜式的缓存控件，存取方式类似于NSDictionary，工作方式与苹果的内存管理体系相一致，在内存吃紧的时候，它会自动释放存储的对象。所以"
        
        cell.bodyTextLabel.text = text
        
        let labelText = cell.bodyTextLabel.text
        let labelTextNSString = NSString(CString:labelText!, encoding: NSUTF8StringEncoding)
        
        cell.bodyTextLabel.backgroundColor = UIColor.lightGrayColor()
        
        let labelFont = UIFont.systemFontOfSize(17)
        let attributesDictionary = [NSFontAttributeName:labelFont]
        let labelSize = CGSize(width: self.tableView.frame.width-16, height:CGFloat.max)
        let options:NSStringDrawingOptions = [.UsesLineFragmentOrigin,.UsesFontLeading]
        
        let labelRect = labelTextNSString!.boundingRectWithSize(labelSize, options: options, attributes: attributesDictionary,context: nil)
        
        cell.bodyTextLabel.frame = labelRect
        
        //Setup ImageStackView
        configureImageStakView(cell)
        
        return cell
    }

    func configureImageStakView(cell:NBWTableViewBasicCell){
        
        if numberOfImageStackView == 1 {
            cell.imageViewOne.image   = UIImage(named: "cloud_1")
            cell.imageViewTwo.image   = UIImage(named: "cloud_2")
            cell.imageViewThree.image = UIImage(named: "cloud_3")
            cell.imageStack2.hidden   = true
            cell.imageStack3.hidden   = true
        }else if numberOfImageStackView == 2 {
            cell.imageViewOne.image   = UIImage(named: "cloud_1")
            cell.imageViewTwo.image   = UIImage(named: "cloud_2")
            cell.imageViewThree.image = UIImage(named: "cloud_3")
            cell.imageViewFour.image  = UIImage(named: "cloud_4")
            cell.imageViewFive.image  = UIImage(named: "cloud_5")
            cell.imageViewSix.image   = UIImage(named: "cloud_6")
            cell.imageStack3.hidden = true
        }else if numberOfImageStackView == 3{
            cell.imageViewOne.image   = UIImage(named: "cloud_1")
            cell.imageViewTwo.image   = UIImage(named: "cloud_2")
            cell.imageViewThree.image = UIImage(named: "cloud_3")
            cell.imageViewFour.image  = UIImage(named: "cloud_4")
            cell.imageViewFive.image  = UIImage(named: "cloud_5")
            cell.imageViewSix.image   = UIImage(named: "cloud_6")
            cell.imageViewSeven.image = UIImage(named: "cloud_7")
            cell.imageViewEight.image = UIImage(named: "cloud_8")
            cell.imageViewNine.image  = UIImage(named: "cloud_9")
        }else{
            cell.imageStackView.hidden = true
            cell.imageStack2.hidden    = true
            cell.imageStack3.hidden    = true
        }
    }
}
