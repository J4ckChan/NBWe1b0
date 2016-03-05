//
//  NBWMentionTableViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/1/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import SDWebImage

class NBWMentionTableViewController: UITableViewController {
    
    let mentionsURLString = "https://api.weibo.com/2/statuses/mentions.json"
    var mentionsWeiboStatuses = [WeiboStatus]()
    var mentionFetched:WeiboStatus?
    var navigationBarHeight:CGFloat?
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "mentionCell")
        navigationItem.title = "Mention"
        navigationController?.navigationBar.tintColor = UIColor.lightGrayColor()
        navigationBarHeight = navigationController?.navigationBar.frame.height
        
        fetchMentionsDataFromWeibo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Weibo.com
    func fetchMentionsDataFromWeibo(){
       Alamofire.request(.GET, mentionsURLString, parameters: ["access_token":accessToken,"count":20], encoding: ParameterEncoding.URL, headers: nil)
        .responseJSON { (Response) -> Void in
            do{
                let dict = try NSJSONSerialization.JSONObjectWithData(Response.data!, options: .AllowFragments) as! NSDictionary
                let array = dict["statuses"] as! NSArray

                self.importJSONIntoCoreData(array)
                
                self.tableView.reloadData()
                
            }catch let error as NSError {
                print("Fetch Data Error:\(error.localizedDescription)")
            }
        }
    }
    
    //Mark: - CoreData 
    func importJSONIntoCoreData(mentionsArray:NSArray){
        
        mentionsWeiboStatuses = []
        
        for mention in mentionsArray {
            
            let id = mention["idstr"] as? String
            let isExisted = fetchDataFromCoreData(id!)
            
            if !isExisted {
                let weiboStatus              = weiboStatusManagedObject()
                importStatusDataFromJSON(weiboStatus, jsonDict: mention as! NSDictionary)
                
                let weiboUser                = weiboUserManagedObject()
                let userDict                 = mention["user"] as? NSDictionary
                importUserDataFromJSON(weiboUser, userDict:userDict!)
                weiboStatus.user             = weiboUser
                
                let retweetedStatus          = weiboStatusManagedObject()
                let retweeted_statusDict     = mention["retweeted_status"] as? NSDictionary
                importStatusDataFromJSON(retweetedStatus, jsonDict: retweeted_statusDict!)
                weiboStatus.retweeted_status = retweetedStatus
                
                let retweetedUser = weiboUserManagedObject()
                let retweetedUserDict = retweeted_statusDict!["user"] as? NSDictionary
                importUserDataFromJSON(retweetedUser, userDict: retweetedUserDict!)
                weiboStatus.retweeted_status?.user = retweetedUser
                
                mentionsWeiboStatuses.append(weiboStatus)
            }
        }
        
        managerContextSave()
    }
    
    func fetchDataFromCoreData(id:String)->Bool{
        
        let request = NSFetchRequest(entityName: "WeiboStatus")
        request.predicate = NSPredicate(format: "id == \(id)")
        
        do {
            let mentionsArray = try managerContext?.executeFetchRequest(request) as! [WeiboStatus]
            if mentionsArray.count == 0 {
                return false
            }else{
                mentionFetched = mentionsArray[0]
                mentionsWeiboStatuses.append(mentionFetched!)
            }
        }catch let error as NSError{
            print("Fetching Error:\(error.localizedDescription)")
        }
    
        return true
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mentionsWeiboStatuses.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mentionCell", forIndexPath: indexPath)
        
        let mention = mentionsWeiboStatuses[indexPath.row]
        // Configure the cell...
        configureMentionTabelViewCell(mention,cell)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let heightNoIncludingTextLabel:CGFloat = 194
        let mention                            = mentionsWeiboStatuses[indexPath.row]
        let textLabelHeight                    = calculateTextLabelHeight(mention.text!, fontSize: 17, viewWidth: tableView.frame.width)
        let height                             = heightNoIncludingTextLabel + textLabelHeight
        
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mention = mentionsWeiboStatuses[indexPath.row]
        let contextVC = NBWeiboContextBasicViewController.init(id: mention.id!, tableViewBool: false)
        navigationController?.pushViewController(contextVC, animated: true)
    }
    
    func configureMentionTabelViewCell(mention:WeiboStatus,_ cell:UITableViewCell){
        
        let avaterString = mention.user?.avatar_large
      
        let labelHeight                 = calculateTextLabelHeight(mention.text!, fontSize: 17, viewWidth: tableView.frame.width)
      
        setupHeaderOfStatusView(cell.contentView, avaterString!, (mention.user?.screen_name)!, mention.created_at!, mention.source!, mention.text!, view.frame.width)

        let repostView                  = UIView(frame: CGRect(x: 8, y: 64 + labelHeight, width: view.frame.width - 16, height: 80))
        repostView.backgroundColor      = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)

        cell.contentView.addSubview(repostView)
        
        let imageURLString = mention.retweeted_status?.bmiddle_pic
        let name = mention.retweeted_status?.user?.screen_name
        let context = mention.retweeted_status?.text
        
        statusViewInBrief(repostView, imageURLString: imageURLString!, name: name!, context: context!)

        let repostCommentLikeBarView    = UIView(frame: CGRect(x: 0, y: 152 + labelHeight, width: view.frame.width, height: 42))

        cell.contentView.addSubview(repostCommentLikeBarView)

        let separatorHeader             = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0.5))
        separatorHeader.backgroundColor = UIColor.grayColor()

        let separator                   = UIView(frame: CGRect(x: 0, y: 32, width: view.frame.width, height: 10))
        separator.backgroundColor       = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)

        repostCommentLikeBarView.addSubview(separator)
        repostCommentLikeBarView.addSubview(separatorHeader)


        let repostButton                = UIButton(frame: CGRect(x: 0, y: 1, width: view.frame.width/3, height: 31))
        repostButton.setTitle(" Repost", forState: .Normal)
        repostButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        repostButton.titleLabel?.font   = UIFont.systemFontOfSize(15, weight: UIFontWeightThin)
        repostButton.setImage(UIImage(named: "repost32"), forState: .Normal)
        repostButton.addTarget(self, action: Selector("repostWeiboStatus:"), forControlEvents: .TouchUpInside)

        let commentButton               = UIButton(frame: CGRect(x: view.frame.width/3, y: 1, width: view.frame.width/3, height: 31))
        commentButton.setTitle(" Comment", forState: .Normal)
        commentButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        commentButton.titleLabel?.font  = UIFont.systemFontOfSize(15, weight: UIFontWeightThin)
        commentButton.setImage(UIImage(named: "comment32"), forState: .Normal)
        commentButton.addTarget(self, action: Selector("commentWeiboStatus:"), forControlEvents: .TouchUpInside)

        let likeButton                  = UIButton(frame: CGRect(x: 2*(view.frame.width/3), y: 1, width: view.frame.width/3, height: 31))
        likeButton.setTitle(" Like", forState: .Normal)
        likeButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        likeButton.titleLabel?.font     = UIFont.systemFontOfSize(15, weight: UIFontWeightThin)
        likeButton.setImage(UIImage(named: "like32"), forState: .Normal)
        likeButton.addTarget(self, action: Selector("likeWeiboStatus:"), forControlEvents: .TouchUpInside)
        
        let arrowButton = UIButton(frame: CGRect(x: view.frame.width - 50, y: 8, width: 50, height: 20))
        arrowButton.setImage(UIImage(named: "arrow32"), forState: .Normal)
        arrowButton.addTarget(self, action: Selector("arrowWeiboStatus:"), forControlEvents: .TouchUpInside)

        repostCommentLikeBarView.addSubview(repostButton)
        repostCommentLikeBarView.addSubview(commentButton)
        repostCommentLikeBarView.addSubview(likeButton)
        cell.contentView.addSubview(arrowButton)
    }
    
    //MARK: - UIButton
    func repostWeiboStatus(sender:AnyObject){
        
        let cell = sender.superview!!.superview?.superview as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let mention = mentionsWeiboStatuses[(indexPath?.row)!]
        let repostVC = NBWRespotViewController.init(weiboStatus: mention, navigationBarHeight: navigationBarHeight!)
        self.presentViewController(repostVC, animated: true, completion: nil)
    }
    
    func commentWeiboStatus(sender:AnyObject){
        
        let cell = sender.superview!!.superview?.superview as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let mention = mentionsWeiboStatuses[(indexPath?.row)!]
        let weiboContextStatusVC = NBWeiboContextBasicViewController.init(id: mention.id!, tableViewBool: true)
        navigationController?.pushViewController(weiboContextStatusVC, animated: true)
    }
    
    func likeWeiboStatus(sender:AnyObject){
        print("API NOT Found")
    }
    
    func arrowWeiboStatus(sender:AnyObject){
        
//        let cell = sender.superview!!.superview as! UITableViewCell
//        let indexPath = tableView.indexPathForCell(cell)
//        let mention = mentionsWeiboStatuses[(indexPath?.row)!]
        
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .ActionSheet)
        let shieldAction = UIAlertAction.init(title: "Shield", style: .Default) { (UIAlertAction) -> Void in
            print("API Need High Authority")
        }
        let blockAction = UIAlertAction.init(title: "Block", style: .Default) { (UIAlertAction) -> Void in
            print("API NOT Found")
        }
        let reportAction = UIAlertAction.init(title: "Report", style: .Default) { (UIAlertAction) -> Void in
            print("API NOT Found")
        }
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .Cancel, handler: nil)
        
        alertController.addAction(shieldAction)
        alertController.addAction(blockAction)
        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}
