//
//  NBWRespotViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 2/17/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit
import Alamofire

class NBWRespotViewController: NBWBasicViewController {
    
    let repostURLString = "https://api.weibo.com/2/statuses/repost.json"
    var isComment = 0
    var weiboStatus:WeiboStatus?
    
    //WeiboStatusView
    var weiboStatusView:UIView?
    var weiboStatusImageView:UIImageView?
    var screenNameLabel:UILabel?
    var bodyTextLabel:UILabel?
    
    var alsoCommentButton:UIButton?
    var alsoCommentBool = false
    
    init(weiboStatus:WeiboStatus, navigationBarHeight: CGFloat) {
        super.init(id:weiboStatus.id!, navigationBarHeight: navigationBarHeight)
        self.weiboStatus = weiboStatus
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationBasicItem?.title = "Repost"
        
        setupWeiboRepost()
        
        setupAlsoCommentButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func sendTextViewContext() {
        super.sendTextViewContext()
        
        if self.textView?.text == "" {
            self.textView?.text = "Repost Weibo"
        }
        
        Alamofire.request(.POST, repostURLString, parameters:["access_token":accessToken,"id":self.id!,"status":(self.textView?.text)!,"is_comment":self.isComment], encoding: ParameterEncoding.URL, headers: nil)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupWeiboRepost(){
       
        self.weiboStatusView = UIView.init(frame: CGRect(x: 8, y: 200, width: self.view.frame.width - 16, height: 80))
        self.weiboStatusView?.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        
        self.weiboStatusImageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        
        self.weiboStatusView?.addSubview(self.weiboStatusImageView!)
        
        self.screenNameLabel = UILabel.init(frame: CGRect(x: 88, y: 8, width: self.view.frame.width-112, height: 20))
        self.weiboStatusView?.addSubview(self.screenNameLabel!)
        
        self.bodyTextLabel = UILabel.init(frame: CGRect(x: 88, y: 32, width: self.view.frame.width-112, height: 48))
        self.bodyTextLabel?.numberOfLines = 0
        self.bodyTextLabel?.font = UIFont.systemFontOfSize(15, weight: UIFontWeightThin)
        self.bodyTextLabel?.textColor = UIColor.lightGrayColor()
        self.weiboStatusView?.addSubview(self.bodyTextLabel!)
        
        self.view.addSubview(self.weiboStatusView!)
        
        if self.weiboStatus?.retweeted_status != nil {
            
            self.textView?.text = "//\((self.weiboStatus?.text)!)"
            self.screenNameLabel?.text = "@\((self.weiboStatus?.retweeted_status?.user?.screen_name)!)"
            self.bodyTextLabel?.text = self.weiboStatus?.retweeted_status?.text
            
            if self.weiboStatus?.retweeted_status?.bmiddle_pic != nil {
                self.weiboStatusImageView?.sd_setImageWithURL(NSURL(string: (self.weiboStatus?.retweeted_status?.bmiddle_pic)!))
            }else{
                self.weiboStatusImageView?.sd_setImageWithURL(NSURL(string: (self.weiboStatus?.user?.avatar_large)!))
            }
        }else{
            
            self.screenNameLabel?.text = "@\((self.weiboStatus?.user?.screen_name)!)"
            self.bodyTextLabel?.text = self.weiboStatus?.text
            
            if self.weiboStatus?.bmiddle_pic != nil {
                self.weiboStatusImageView?.sd_setImageWithURL(NSURL(string: (self.weiboStatus?.bmiddle_pic)!))
            }else{
                self.weiboStatusImageView?.sd_setImageWithURL(NSURL(string: (self.weiboStatus?.user?.avatar_large)!))
            }
        }
    }
    
    func setupAlsoCommentButton(){
        self.alsoCommentButton = UIButton.init(frame: CGRect(x: 8, y: self.view.frame.height - 330, width: 150, height: 20))
        self.alsoCommentButton?.setTitle("  Also Comment", forState: .Normal)
        self.alsoCommentButton?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.alsoCommentButton?.titleLabel?.font = UIFont.systemFontOfSize(15)
        self.alsoCommentButton?.setImage(UIImage(named: "frame"), forState: .Normal)
        self.alsoCommentButton?.addTarget(self, action: Selector("alsoCommentOrNot"), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(self.alsoCommentButton!)
    }
    
    func alsoCommentOrNot(){
       
        if alsoCommentBool == false {
            self.alsoCommentBool = true
            self.alsoCommentButton?.setImage(UIImage(named: "tick"), forState: .Normal)
            self.isComment = 1
        }else{
            self.alsoCommentBool = false
            self.alsoCommentButton?.setImage(UIImage(named: "frame"), forState: .Normal)
            self.isComment = 0
        }
    }
    
}
