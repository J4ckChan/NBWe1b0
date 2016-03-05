//
//  NBWCommentTableViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/3/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import SDWebImage

class NBWCommentTableViewController: UITableViewController {
    
    let commentToMeURLString = "https://api.weibo.com/2/comments/to_me.json"
    var commentArray = [Comment]()
    var filterByAuthor = 0
    var midButton:UIButton?
    var midButtonTitle:String = "All Comments"
    
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
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "commentIdentifier")

        navigationController?.navigationBar.tintColor = UIColor.lightGrayColor()
        
        setupMidBarButtonItem()
        
        fetchCommentDataFromWeibo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        managerContextSave()
    }
    
    //MARK: - UIButton
    
    func setupMidBarButtonItem(){
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        midButton = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        midButton?.setTitle(midButtonTitle, forState: .Normal)
        midButton?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        midButton?.titleLabel?.font = UIFont.systemFontOfSize(15, weight: UIFontWeightBold)
        midButton?.addTarget(self, action: Selector("filterComments:"), forControlEvents: .TouchUpInside)
        view.addSubview(midButton!)
        
        navigationItem.titleView = view
    }
    
    func filterComments(sender:AnyObject){
        
        let filterCommentVC = NBWFilterCommentTableViewController.init()
        filterCommentVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        filterCommentVC.preferredContentSize = CGSize(width: 150, height: 120)
        filterCommentVC.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        filterCommentVC.indexDelegate = self
        
        let popover = filterCommentVC.popoverPresentationController
        popover?.sourceView = filterCommentVC.view
        popover?.sourceRect = CGRect(x: (view.frame.width/2), y: (navigationController?.navigationBar.frame.height)! - 10, width: 0, height: 0)
        popover?.delegate = self
        presentViewController(filterCommentVC, animated: true, completion: nil)
    }
    
    //MARK: - Weibo.com
    
    func fetchCommentDataFromWeibo(){
        
        Alamofire.request(.GET, commentToMeURLString, parameters: ["access_token":accessToken,"count":5,"filter_by_author":filterByAuthor], encoding: ParameterEncoding.URL, headers: nil)
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
    
    //MARK: - CoreData
    
    func commentIntoCoreData(array:NSArray){
        
        commentArray = []
       
        for commentDict in array {
            
            let idstr = commentDict["idstr"] as? String
            if !commentAlreadyExisted(idstr!) {

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
        
        tableView.reloadData()
    }
    
    

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return commentArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentIdentifier", forIndexPath: indexPath)

        // Configure the cell...
        let comment = commentArray[indexPath.row]
        configureCommentTableViewCell(comment, cell)

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let comment = commentArray[indexPath.row]
        let textLabelHeight = calculateTextLabelHeight(comment.text!, fontSize: 15, viewWidth: view.frame.width - 16)
        if comment.reply_comment == nil {
            return 152 + textLabelHeight
        }else{
            let name = comment.reply_comment?.user?.screen_name
            let text = "@\(name!): \((comment.reply_comment?.text)!)"
            let replyCommentLableHeight = calculateTextLabelHeight(text, fontSize: 15, viewWidth: view.frame.width - 16)
            return 160 + textLabelHeight + replyCommentLableHeight
        }
    }
    
    func configureCommentTableViewCell(comment:Comment,_ cell:UITableViewCell){
        
        let avater                      = UIImageView(frame: CGRect(x: 8, y: 8, width: 40, height: 40))
        avater.sd_setImageWithURL(NSURL(string: (comment.user?.avatar_large)!))
        
        let screenNameLabel             = UILabel(frame: CGRect(x: 56, y: 8, width: 200, height: 20))
        screenNameLabel.text            = comment.user?.screen_name
        screenNameLabel.font            = UIFont.systemFontOfSize(15)
        
        let createdAtLabel              = UILabel(frame: CGRect(x: 56, y: 32, width: view.frame.width - 64, height: 16))
        createdAtLabel.text             = createdAtLabelText(comment.created_at!, source: comment.source!)
        createdAtLabel.font             = UIFont.systemFontOfSize(13, weight: UIFontWeightThin)
        
        let labelHeight                 = calculateTextLabelHeight(comment.text!,fontSize: 15,viewWidth: view.frame.width)
        let textLabel                   = UILabel(frame: CGRect(x: 8, y: 56, width: view.frame.width - 16, height: labelHeight))
        textLabel.text                  = comment.text
        textLabel.numberOfLines         = 0
        textLabel.font                  = UIFont.systemFontOfSize(15, weight: UIFontWeightThin)
        
        cell.contentView.addSubview(avater)
        cell.contentView.addSubview(screenNameLabel)
        cell.contentView.addSubview(createdAtLabel)
        cell.contentView.addSubview(textLabel)
        
        if comment.reply_comment == nil {
            let statusView = UIView(frame: CGRect(x: 8, y: 64 + labelHeight, width: view.frame.width - 16, height: 80))
            statusView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
            cell.contentView.addSubview(statusView)
            
            let statusImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            if comment.status?.bmiddle_pic != nil {
                statusImageView.sd_setImageWithURL(NSURL(string: (comment.status?.bmiddle_pic)!))
            }else{
                if comment.status?.retweeted_status != nil {
                    if comment.status?.retweeted_status?.bmiddle_pic != nil {
                        statusImageView.sd_setImageWithURL(NSURL(string: (comment.status?.retweeted_status?.bmiddle_pic)!))
                    }else{
                        statusImageView.sd_setImageWithURL(NSURL(string: (comment.status?.user?.avatar_large)!))
                    }
                }else{
                    statusImageView.sd_setImageWithURL(NSURL(string: (comment.user?.avatar_large)!))
                }
            }
            statusView.addSubview(statusImageView)
            
            let statusUserLabel = UILabel(frame: CGRect(x: 88, y: 8, width: 100, height: 18))
            statusUserLabel.text = "@\((comment.status?.user?.screen_name)!)"
            statusUserLabel.font = UIFont.systemFontOfSize(15)
            statusView.addSubview(statusUserLabel)
            
            let statusTextLable = UILabel(frame: CGRect(x: 88, y: 30, width: statusView.frame.width - 88, height: 48))
            statusTextLable.font = UIFont.systemFontOfSize(13, weight: UIFontWeightThin)
            statusTextLable.numberOfLines = 0
            if comment.status?.retweeted_status != nil {
                let name = comment.status?.retweeted_status?.user?.screen_name
                let text = comment.status?.retweeted_status?.text
                statusTextLable.text = "\((comment.status?.text)!)//@\(name!):\(text!)"
            }else{
                statusTextLable.text = comment.status?.text
            }
            statusView.addSubview(statusTextLable)
        }else{
            let name = comment.reply_comment?.user?.screen_name
            let text = "@\(name!): \((comment.reply_comment?.text)!)"
            let replyCommentLabelHeight = calculateTextLabelHeight(text, fontSize: 15, viewWidth: view.frame.width - 16)
            
            let replyCommentView = UIView(frame: CGRect(x: 0, y: 64 + labelHeight, width: view.frame.width, height: 96 + replyCommentLabelHeight))
            replyCommentView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
            cell.contentView.addSubview(replyCommentView)
            
            let replyCommentLabel = UILabel(frame: CGRect(x: 8, y: 0, width: view.frame.width - 16, height: replyCommentLabelHeight))
            replyCommentLabel.text = text
            replyCommentLabel.font = UIFont.systemFontOfSize(15, weight: UIFontWeightThin)
            replyCommentLabel.numberOfLines = 0
            replyCommentView.addSubview(replyCommentLabel)
            
            let statusView = UIView(frame: CGRect(x: 8, y: replyCommentLabelHeight + 8, width: view.frame.width - 16, height: 80))
            statusView.backgroundColor = UIColor.whiteColor()
            replyCommentView.addSubview(statusView)
            
            let statusImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            statusView.addSubview(statusImageView)
            
            if comment.status?.bmiddle_pic != nil {
                statusImageView.sd_setImageWithURL(NSURL(string: (comment.status?.bmiddle_pic)!))
            }else{
                if comment.status?.retweeted_status != nil {
                    if comment.status?.retweeted_status?.bmiddle_pic != nil {
                        statusImageView.sd_setImageWithURL(NSURL(string: (comment.status?.retweeted_status?.bmiddle_pic)!))
                    }else{
                        statusImageView.sd_setImageWithURL(NSURL(string: (comment.status?.user?.avatar_large)!))
                    }
                }else{
                    statusImageView.sd_setImageWithURL(NSURL(string: (comment.user?.avatar_large)!))
                }
            }
            
            let nameLabel = UILabel(frame: CGRect(x: 88, y: 8, width: 100, height: 18))
            nameLabel.font = UIFont.systemFontOfSize(15)
            nameLabel.text = "@\((comment.status?.user?.screen_name)!)"
            statusView.addSubview(nameLabel)
            
            let replyCommentTextLabel = UILabel(frame: CGRect(x: 88, y: 30, width: statusView.frame.width - 96, height: 42))
            replyCommentTextLabel.numberOfLines = 0
            replyCommentTextLabel.font = UIFont.systemFontOfSize(13, weight: UIFontWeightThin)
            replyCommentTextLabel.text = comment.status?.text
            statusView.addSubview(replyCommentTextLabel)
        }
    }
}

//MARK: - UIPopoverPresentationControllerDelegate

extension NBWCommentTableViewController:UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}

extension NBWCommentTableViewController:SendIndexDelegate{
    func sendIndex(index: Int) {
        filterByAuthor = index
        fetchCommentDataFromWeibo()
    }
}
