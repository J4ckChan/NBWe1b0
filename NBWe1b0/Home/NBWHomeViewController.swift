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
import SDWebImage

var managerContext:NSManagedObjectContext?
var tableViewCellWidth:CGFloat?
var navigationBarHeight:CGFloat?

class NBWHomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userNameButton: UIButton!
    
    let homeTimelineURL           = "https://api.weibo.com/2/statuses/home_timeline.json"
    let basicReuseIdentifier      = "BasicCell"
    let multiImageReuseIdentifier = "ImageCell"
    let repostReuseIdentifier     = "RepostCell"
    
    var refreshHeaderController:UIRefreshControl?
//    var refreshFooterController:UIRefreshControl?
    var cellCache:NSCache?
    var numberOfImageRow:CGFloat?
    var numberOfRespostCellImageRow:CGFloat?
    var weiboStatusesArray = [WeiboStatus]()
    var searchController:UISearchController?
    var hasImage:Bool?
    var hasMultiImage:Bool?
    var hasRepost:Bool?
    var nameButtonViewBool = false
    var nameButtonView:UIView?
    var nameButtonBackgroundImageView:UIImageView?
    var nameButtonBackgroundArrowImageView:UIImageView?
    var nameButtonTableViewController:NBWNameButtonTableViewController?
    
    var selectedWeiboStatus:WeiboStatus?
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        self.tableView.dataSource = self
        self.tableView.delegate   = self
        tableViewCellWidth = self.view.frame.width
        navigationBarHeight = self.navigationController?.navigationBar.frame.height
        
        cellCache = NSCache.init()
        
        //CoreData
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managerContext = appDelegate.managedObjectContext
        
        setupUserNameButton()
        
        setUpRefresh()
    }
    
    func setupUserNameButton(){
        self.userNameButton.setTitle(userScreenName, forState: .Normal)
        self.userNameButton.addTarget(self, action: Selector("showNameButtonView:"), forControlEvents: .TouchUpInside)
    }
    
    func setUpRefresh(){
        
        //HeaderRefresh
        self.refreshHeaderController = UIRefreshControl.init()
        self.tableView.addSubview(self.refreshHeaderController!)
        self.refreshHeaderController?.tintColor = UIColor.orangeColor()
        let attributedStrDict = [NSForegroundColorAttributeName:UIColor.orangeColor()]
        self.refreshHeaderController?.attributedTitle = NSAttributedString.init(string: "Refresh Data", attributes: attributedStrDict)
        
        self.refreshHeaderController!.addTarget(self, action: Selector("homeTimelineFetchDataFromWeibo:"), forControlEvents: .ValueChanged)
        
        homeTimelineFetchDataFromWeibo(self)
        
        self.fetchDataFromCoreData()
    }
    
    //MARK: - Button
    @IBAction func weiboLogin(sender: UIBarButtonItem) {
        let request         = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = redirectURL
        request.scope       = "all"
        
        WeiboSDK.sendRequest(request)
    }
    
    func showNameButtonView(sender:AnyObject){
        
        if nameButtonViewBool {
            nameButtonViewBool = !nameButtonViewBool
            
            nameButtonView?.removeFromSuperview()
            nameButtonBackgroundArrowImageView?.removeFromSuperview()
            
        }else{
            nameButtonViewBool = !nameButtonViewBool
            let center = userNameButton.center
            
            nameButtonView = UIView(frame: CGRect(origin: CGPoint(x: center.x - 100, y: navigationBarHeight! + 10), size: CGSize(width: 200, height: 300)))
            nameButtonBackgroundImageView = UIImageView(image: UIImage(named: "nameButtonView"))
            nameButtonBackgroundImageView?.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
            nameButtonView?.addSubview(nameButtonBackgroundImageView!)
            
            nameButtonTableViewController = NBWNameButtonTableViewController.init(frame: CGRect(x: 0, y: 10, width: 200, height: 290))
            nameButtonView?.addSubview((nameButtonTableViewController?.tableView)!)
            
            nameButtonBackgroundArrowImageView = UIImageView(image: UIImage(named: "nameButtonViewArrow"))
            
            nameButtonBackgroundArrowImageView?.frame = CGRect(x: center.x - 100, y: navigationBarHeight! - 10, width: 200, height: 10)
            
            navigationController?.navigationBar.addSubview(nameButtonBackgroundArrowImageView!)
            view.addSubview(nameButtonView!)
        }
    }
    
    
    //MARK: - Weibo.com
    func homeTimelineFetchDataFromWeibo(sender:AnyObject){
        
        self.refreshHeaderController!.beginRefreshing()
        
        Alamofire.request(.GET, homeTimelineURL, parameters: ["access_token":accessToken,"count":5], encoding: ParameterEncoding.URL, headers: nil)
            .responseJSON { (response) -> Void in
                
                do {
                   let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(response.data!, options: .AllowFragments) as! NSDictionary
                    let statusesArrary = jsonDictionary.valueForKey("statuses") as! NSArray
                    
                    self.importJSONInCoreData(statusesArrary)
                    
                }catch let error as NSError{
                    print("Error:\(error.localizedDescription)")
                }
                self.refreshHeaderController?.endRefreshing()
            }
    }
    
    //MARK: - CoreData
    func importJSONInCoreData(statuesArray:NSArray){
    
        // weibo status is stored in WeiboStatus from CoreData
        weiboStatusPesistentlyStoreInCoreData(statuesArray)
        
        managerContextSave()
        
        fetchDataFromCoreData()
        
        self.tableView.reloadData()
    }
    
    func weiboStatusPesistentlyStoreInCoreData(statuesArray:NSArray){
        
        for jsonDict in statuesArray {
            
            //compare idstr
            fetchDataFromCoreData()
            
            var flag = true
            for status in weiboStatusesArray {
                let id = jsonDict["idstr"] as? String
                if id == status.id {
                    flag = false
                }
            }
            
            if flag == true {
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
    func hasImageOrMutilImageAndRepostOrNot(weiboStatus:WeiboStatus){
        
        if weiboStatus.pics?.count < 1 {
            self.hasImage = false
            self.hasMultiImage = false
            self.numberOfImageRow = 0
        }else if weiboStatus.pics?.count == 1{
            self.hasImage = true
            self.hasMultiImage = false
            self.numberOfImageRow = 1
        }else if weiboStatus.pics?.count > 1{
            self.hasImage = true
            self.hasMultiImage = true
            if weiboStatus.pics?.count > 3 {
                self.numberOfImageRow = 2
            }else if weiboStatus.pics?.count == 0{
                self.numberOfImageRow = 0
            }else{
                self.numberOfImageRow = 1
            }
        }
        
        if weiboStatus.retweeted_status == nil {
            self.hasRepost = false
        }else{
            self.hasRepost = true
            if weiboStatus.retweeted_status?.pics?.count > 3 {
                self.numberOfRespostCellImageRow = 2
            }else if weiboStatus.retweeted_status?.pics?.count == 0 {
                self.numberOfRespostCellImageRow = 0
            }else{
                self.numberOfRespostCellImageRow = 1
            }
        }
      
//        print("hasImage:\(hasImage!) hasMultiImage:\(hasMultiImage!) pics number:\((weiboStatus.pics?.count)!) hasRepost:\(hasRepost!) pic number in repost:\(self.numberOfRespostCellImageRow!)")
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
        
        let weiboStatus = weiboStatusesArray[indexPath.row]
        
        hasImageOrMutilImageAndRepostOrNot(weiboStatus)
        
        if hasRepost == false {
            if hasMultiImage == false{
                var cell = self.cellCache?.objectForKey(key) as? NBWTableViewBasicCell
                
                if cell == nil {
                    cell = tableView.dequeueReusableCellWithIdentifier(basicReuseIdentifier) as? NBWTableViewBasicCell
                    cell?.viewController = self
                    cell?.configureHomeTableViewBasicCell(cell!, weiboStatus:weiboStatus, tableView: tableView, hasImage: self.hasImage!)
                }else {
                    cell?.configureHomeTableViewBasicCell(cell!, weiboStatus:weiboStatus, tableView: tableView, hasImage: self.hasImage!)
                }
                
                return cell!
            }else{
                var cell = self.cellCache?.objectForKey(key) as? NBWTableViewImageCell
                
                if cell == nil {
                    cell = tableView.dequeueReusableCellWithIdentifier(multiImageReuseIdentifier) as? NBWTableViewImageCell
                    cell?.viewController = self
                    cell?.configureMultiImageCell(cell!, weiboStatus:weiboStatus, tableView: tableView)
                }else{
                    cell?.configureMultiImageCell(cell!, weiboStatus:weiboStatus, tableView: tableView)
                }
                return cell!
            }
        }else{
            var cell = self.cellCache?.objectForKey(key) as? NBWTableViewRepostCell
            
            if cell == nil {
                cell = tableView.dequeueReusableCellWithIdentifier(repostReuseIdentifier) as? NBWTableViewRepostCell
                cell?.viewController = self
                cell?.configureRespostCell(cell!, weiboStatus: weiboStatus, tableView: tableView,numberOfImageRow: self.numberOfRespostCellImageRow!)
            }else{
                cell?.configureRespostCell(cell!, weiboStatus: weiboStatus, tableView: tableView,numberOfImageRow: self.numberOfRespostCellImageRow!)
            }
            return cell!
        }
    }
    
    //HeightForRow
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let key:String = "\(indexPath.section)-\(indexPath.row)"
        
        let weiboStatus = self.weiboStatusesArray[indexPath.row]
        
        hasImageOrMutilImageAndRepostOrNot(weiboStatus)
        
        var cellHeight:CGFloat?
        
        if hasRepost == false {
            if hasMultiImage == false {
                var cell = self.cellCache?.objectForKey(key) as?NBWTableViewBasicCell
                
                if cell == nil {
                    cell = tableView.dequeueReusableCellWithIdentifier(basicReuseIdentifier) as? NBWTableViewBasicCell
                    cell?.configureHomeTableViewBasicCell(cell!, weiboStatus:weiboStatus,tableView: tableView, hasImage: self.hasImage!)
                    self.cellCache?.setObject(cell!, forKey: key)
                    cellHeight = cell?.calculateBasicCell(cell!, hasImage: hasImage!)
                }else{
                    cellHeight = cell?.calculateBasicCell(cell!, hasImage: self.hasImage!)
                }
            }else{
                var cell = self.cellCache?.objectForKey(key) as? NBWTableViewImageCell
                
                if cell == nil {
                    cell = tableView.dequeueReusableCellWithIdentifier(multiImageReuseIdentifier) as? NBWTableViewImageCell
                    cell?.configureMultiImageCell(cell!, weiboStatus: weiboStatus, tableView: tableView)
                    self.cellCache?.setObject(cell!, forKey: key)
                    cellHeight = cell?.calculateImageCell(cell!,numberOfImageRow: self.numberOfImageRow!)
                }else{
                    cellHeight = cell?.calculateImageCell(cell!, numberOfImageRow: self.numberOfImageRow!)
                }
            }
        }else{
            var cell = self.cellCache?.objectForKey(key) as? NBWTableViewRepostCell
            
            if cell == nil {
                cell = tableView.dequeueReusableCellWithIdentifier(repostReuseIdentifier) as? NBWTableViewRepostCell
                cell?.configureRespostCell(cell!, weiboStatus: weiboStatus, tableView: tableView,numberOfImageRow: self.numberOfRespostCellImageRow!)
                self.cellCache?.setObject(cell!, forKey: key)
                cellHeight = cell?.calculateRepostCellHeight(cell!, numberOfImageRow: self.numberOfRespostCellImageRow!)
            }else{
                cellHeight = cell?.calculateRepostCellHeight(cell!, numberOfImageRow: self.numberOfRespostCellImageRow!)
            }
        }
        
        return cellHeight!
    }
    
    //The Background of selected Cell disappear
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let weiboStatus = weiboStatusesArray[indexPath.row]
        
        let weiboContextBasicViewController = NBWeiboContextBasicViewController.init(id: weiboStatus.id!,tableViewBool: false)
        weiboContextBasicViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(weiboContextBasicViewController, animated: true)
    }

    func repostWeiboStatus(sender:AnyObject){
        
        let cell = sender.superview!!.superview!.superview as! UITableViewCell
        
        let indexPath = self.tableView.indexPathForCell(cell)
        
        self.selectedWeiboStatus = self.weiboStatusesArray[(indexPath?.row)!]
        
        let repostViewController = NBWRespotViewController.init(weiboStatus: self.selectedWeiboStatus!, navigationBarHeight: navigationBarHeight!)
        self.navigationController?.presentViewController(repostViewController, animated: true, completion: nil)
    }
    
    func commentWeiboStatus(sender:AnyObject){
        
        let cell = sender.superview!!.superview?.superview as! UITableViewCell
        
        let indexPath = self.tableView.indexPathForCell(cell)
        
        self.selectedWeiboStatus = self.weiboStatusesArray[indexPath!.row]
        
        let contextViewController = NBWeiboContextBasicViewController.init(id: self.selectedWeiboStatus!.id!, tableViewBool: true)
        
        contextViewController.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(contextViewController, animated: true)
    }
}
