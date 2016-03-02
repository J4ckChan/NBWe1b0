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
    var tableViewHeightArray = [CGFloat]()
    
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
        
        tableViewHeightArray = []
        
        let heightNoIncludingTextLabel:CGFloat = 194
        let mention                            = mentionsWeiboStatuses[indexPath.row]
        let textLabelHeight                    = calculateTextLabelHeight(mention.text!)
        let height                             = heightNoIncludingTextLabel + textLabelHeight
        
        return height
    }
    
    func configureMentionTabelViewCell(mention:WeiboStatus,_ cell:UITableViewCell){
        
        let avater = UIImageView(frame: CGRect(x: 8, y: 8, width: 40, height: 40))
        avater.sd_setImageWithURL(NSURL(string: (mention.user?.avatar_large)!))
        
        let screenNameLabel = UILabel(frame: CGRect(x: 56, y: 8, width: view.frame.width - 64, height: 20))
        screenNameLabel.text = mention.user?.screen_name
        screenNameLabel.font = UIFont.systemFontOfSize(15)
        
        let createdAtLabel = UILabel(frame: CGRect(x: 56, y: 32, width: view.frame.width - 64, height: 16))
        createdAtLabel.text = "\((mention.source)!)"
        createdAtLabel.font = UIFont.systemFontOfSize(13, weight: UIFontWeightThin)
        
        let labelHeight = calculateTextLabelHeight(mention.text!)
        let textLabel = UILabel(frame: CGRect(x: 8, y: 56, width: view.frame.width - 16, height: labelHeight))
        textLabel.text = mention.text
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFontOfSize(17, weight: UIFontWeightThin)
        
        cell.contentView.addSubview(avater)
        cell.contentView.addSubview(screenNameLabel)
        cell.contentView.addSubview(createdAtLabel)
        cell.contentView.addSubview(textLabel)
        
        let repostView = UIView(frame: CGRect(x: 8, y: 64 + labelHeight, width: view.frame.width - 16, height: 80))
        repostView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        
        cell.contentView.addSubview(repostView)
        
        let repostImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        repostImageView.sd_setImageWithURL(NSURL(string: (mention.retweeted_status?.bmiddle_pic)!))
        
        let repostScreenNameLabel = UILabel(frame: CGRect(x: 88, y: 8, width: repostView.frame.width, height: 18))
        repostScreenNameLabel.text = mention.retweeted_status?.user?.screen_name
        repostScreenNameLabel.font = UIFont.systemFontOfSize(15)
        
        let repostTextLabel = UILabel(frame: CGRect(x: 88, y: 30, width: repostView.frame.width - 88, height: 46))
        repostTextLabel.text = mention.retweeted_status?.text
        repostTextLabel.numberOfLines = 0
        repostTextLabel.font = UIFont.systemFontOfSize(13, weight: UIFontWeightThin)
        
        repostView.addSubview(repostImageView)
        repostView.addSubview(repostScreenNameLabel)
        repostView.addSubview(repostTextLabel)
        
        let repostCommentLikeBarView = UIView(frame: CGRect(x: 0, y: 152 + labelHeight, width: view.frame.width, height: 42))
        
        cell.contentView.addSubview(repostCommentLikeBarView)
        
        let separatorHeader = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 0.5))
        separatorHeader.backgroundColor = UIColor.grayColor()
        
        let separator = UIView(frame: CGRect(x: 0, y: 32, width: view.frame.width, height: 10))
        separator.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        
        repostCommentLikeBarView.addSubview(separator)
        repostCommentLikeBarView.addSubview(separatorHeader)
        
        
        let repostButton = UIButton(frame: CGRect(x: 0, y: 1, width: view.frame.width/3, height: 31))
        repostButton.setTitle(" Repost", forState: .Normal)
        repostButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        repostButton.titleLabel?.font = UIFont.systemFontOfSize(15, weight: UIFontWeightThin)
        repostButton.setImage(UIImage(named: "repost32"), forState: .Normal)
        
        let commentButton = UIButton(frame: CGRect(x: view.frame.width/3, y: 1, width: view.frame.width/3, height: 31))
        commentButton.setTitle(" Comment", forState: .Normal)
        commentButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        commentButton.titleLabel?.font = UIFont.systemFontOfSize(15, weight: UIFontWeightThin)
        commentButton.setImage(UIImage(named: "comment32"), forState: .Normal)
        
        let likeButton = UIButton(frame: CGRect(x: 2*(view.frame.width/3), y: 1, width: view.frame.width/3, height: 31))
        likeButton.setTitle(" Like", forState: .Normal)
        likeButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        likeButton.titleLabel?.font = UIFont.systemFontOfSize(15, weight: UIFontWeightThin)
        likeButton.setImage(UIImage(named: "like32"), forState: .Normal)
        
        repostCommentLikeBarView.addSubview(repostButton)
        repostCommentLikeBarView.addSubview(commentButton)
        repostCommentLikeBarView.addSubview(likeButton)
    }
    
    func calculateTextLabelHeight(text:String)->CGFloat{
        
        let labelText                          = text
        let labelTextNSString                  = NSString(CString:labelText, encoding: NSUTF8StringEncoding)
        let labelFont                          = UIFont.systemFontOfSize(17, weight: UIFontWeightThin)
        let attributesDictionary               = [NSFontAttributeName:labelFont]
        let labelSize                          = CGSize(width: tableView.frame.width-16, height:CGFloat.max)
        let options:NSStringDrawingOptions     = [.UsesLineFragmentOrigin,.UsesFontLeading]
        let labelRect                          = labelTextNSString!.boundingRectWithSize(labelSize, options: options, attributes: attributesDictionary,context: nil)
        
        return labelRect.height
    }
}
