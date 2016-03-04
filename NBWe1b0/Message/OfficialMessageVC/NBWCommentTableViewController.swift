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
        navigationItem.rightBarButtonItem = self.editButtonItem()

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

                let comment           = weiboCommentManagedObject()
                importCommentDataFromJSON(comment, commentDict: commentDict as! NSDictionary)

                let weiboStatus       = weiboStatusManagedObject()
                let weiboStatusDict   = commentDict["status"] as! NSDictionary
                importStatusDataFromJSON(weiboStatus, jsonDict: weiboStatusDict)
                comment.status        = weiboStatus

                let weiboUser         = weiboUserManagedObject()
                let weiboUserDict     = commentDict["user"] as! NSDictionary
                importUserDataFromJSON(weiboUser, userDict: weiboUserDict)
                comment.user          = weiboUser

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
        return 200
    }
    
    func configureCommentTableViewCell(comment:Comment,_ cell:UITableViewCell){
        
        let avater                      = UIImageView(frame: CGRect(x: 8, y: 8, width: 40, height: 40))
        avater.sd_setImageWithURL(NSURL(string: (comment.user?.avatar_large)!))
        
        let screenNameLabel             = UILabel(frame: CGRect(x: 56, y: 8, width: 200, height: 20))
        screenNameLabel.text            = comment.user?.screen_name
        screenNameLabel.font            = UIFont.systemFontOfSize(15)
        
        let createdAtLabel              = UILabel(frame: CGRect(x: 56, y: 32, width: view.frame.width - 64, height: 16))
        createdAtLabel.text             = "\((comment.source)!)"
        createdAtLabel.font             = UIFont.systemFontOfSize(13, weight: UIFontWeightThin)
        
        let labelHeight                 = calculateTextLabelHeight(comment.text!,fontSize: 17,viewWidth: view.frame.width)
        let textLabel                   = UILabel(frame: CGRect(x: 8, y: 56, width: view.frame.width - 16, height: labelHeight))
        textLabel.text                  = comment.text
        textLabel.numberOfLines         = 0
        textLabel.font                  = UIFont.systemFontOfSize(17, weight: UIFontWeightThin)
        
        cell.contentView.addSubview(avater)
        cell.contentView.addSubview(screenNameLabel)
        cell.contentView.addSubview(createdAtLabel)
        cell.contentView.addSubview(textLabel)
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
