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
    
    let timelineURLs = ["https://api.weibo.com/2/statuses/home_timeline.json","https://api.weibo.com/2/statuses/bilateral_timeline.json"]
    var timelineURL               = "https://api.weibo.com/2/statuses/home_timeline.json"
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
    var weiboStatus:WeiboStatus?
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        self.tableView.dataSource = self
        self.tableView.delegate   = self
        tableViewCellWidth = self.view.frame.width
        navigationBarHeight = self.navigationController?.navigationBar.frame.height
        
        //CoreData
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managerContext = appDelegate.managedObjectContext
        
        setupUserNameButton()
        
        setUpRefresh()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        managerContextSave()
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
        
        self.refreshHeaderController!.addTarget(self, action: Selector("timelineFetchDataFromWeibo:"), forControlEvents: .ValueChanged)
        
        timelineFetchDataFromWeibo(self)
        
        fetchDataFromCoreData()
    }
    
    //MARK: - Button
    @IBAction func weiboLogin(sender: UIBarButtonItem) {
        let request         = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = redirectURL
        request.scope       = "all"
        
        WeiboSDK.sendRequest(request)
    }
    
    func showNameButtonView(sender:AnyObject){
        
        let nameButtonTableVC = NBWNameButtonTableViewController.init()
        nameButtonTableVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        nameButtonTableVC.preferredContentSize = CGSize(width: 160, height: 200)
        nameButtonTableVC.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        nameButtonTableVC.indexDelegate = self
        
        let popover = nameButtonTableVC.popoverPresentationController
        popover?.sourceView = nameButtonTableVC.view
        popover?.sourceRect = CGRect(x: userNameButton.center.x, y: userNameButton.center.y + userNameButton.frame.height/2, width: 0, height: 0)
        popover?.delegate = self
        presentViewController(nameButtonTableVC, animated: true, completion: nil)
    }
    
    
    //MARK: - Weibo.com
    func timelineFetchDataFromWeibo(sender:AnyObject){
        
        self.refreshHeaderController!.beginRefreshing()
        
        Alamofire.request(.GET, timelineURL, parameters: ["access_token":accessToken,"count":20], encoding: ParameterEncoding.URL, headers: nil)
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
        
        self.tableView.reloadData()
    }
    
    func weiboStatusPesistentlyStoreInCoreData(statuesArray:NSArray){
        
        weiboStatusesArray = []
        
        for jsonDict in statuesArray {
            
            let id = jsonDict["idstr"] as? String
            
            if weiboStatusAlreadyExisted(id!) {
                
                fetchOneWeiboStatusFromCoreDate(id!)
                
                weiboStatusesArray.append(weiboStatus!)
                
            }else{
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
                
                weiboStatusesArray.append(weiboStatus)
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
    
    //HeightForRow
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let weiboStatus = self.weiboStatusesArray[indexPath.row]
        
        hasImageOrMutilImageAndRepostOrNot(weiboStatus)
        
        var cellHeight:CGFloat?
        
        if hasRepost == false {
            if hasMultiImage == false {
                cellHeight = calculateBasicCell(weiboStatus, hasImage: hasImage!)
            }else{
                cellHeight = calculateImageCell(weiboStatus, numberOfImageRow: numberOfImageRow!)
            }
        }else{
            cellHeight = calculateRepostCellHeight(weiboStatus, numberOfImageRow: numberOfRespostCellImageRow!)
        }
        
        return cellHeight!
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let weiboStatus = weiboStatusesArray[indexPath.row]
        
        hasImageOrMutilImageAndRepostOrNot(weiboStatus)
        
        if hasRepost == false {
            if hasMultiImage == false{
                let cell = tableView.dequeueReusableCellWithIdentifier(basicReuseIdentifier) as? NBWTableViewBasicCell
                cell?.viewController = self
                cell!.configureHomeTableViewBasicCell(cell!, weiboStatus:weiboStatus, tableView: tableView, hasImage: self.hasImage!)
                return cell!
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier(multiImageReuseIdentifier) as? NBWTableViewImageCell
                cell?.viewController = self
                cell!.configureMultiImageCell(cell!, weiboStatus:weiboStatus, tableView: tableView)
                return cell!
            }
        }else{
                let cell = tableView.dequeueReusableCellWithIdentifier(repostReuseIdentifier) as? NBWTableViewRepostCell
                cell?.viewController = self
                cell?.configureRespostCell(cell!, weiboStatus: weiboStatus, tableView: tableView,numberOfImageRow: self.numberOfRespostCellImageRow!)
        return cell!
        }
    }
    
    //The Background of selected Cell disappear
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        managerContextSave()
        
        let weiboStatus = weiboStatusesArray[indexPath.row]
        
        let weiboContextBasicViewController = NBWeiboContextBasicViewController.init(id: weiboStatus.id!,tableViewBool: false)
        weiboContextBasicViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(weiboContextBasicViewController, animated: true)
    }

    func repostWeiboStatus(sender:AnyObject){
        
        let cell = sender.superview!!.superview!.superview as! UITableViewCell
        
        let indexPath = self.tableView.indexPathForCell(cell)
        
        self.selectedWeiboStatus = self.weiboStatusesArray[(indexPath?.row)!]
        
        let repostViewController = NBWRespotViewController.init(weiboStatus: self.selectedWeiboStatus!)
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

//MARK: - UIPopoverPresentationControllerDelegate
extension NBWHomeViewController:UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}

//MARK: - Send TimelineURL 
extension NBWHomeViewController:SendIndexDelegate {
    func sendIndex(index:Int){
        timelineURL = timelineURLs[index]
        timelineFetchDataFromWeibo(self)
    }
}