//
//  NBWCommentViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 2/17/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit
import Alamofire

class NBWCommentViewController: NBWBasicViewController {
    
    let commentCreateURL = "https://api.weibo.com/2/comments/create.json"
    let replyCommentURL  = "https://api.weibo.com/2/comments/reply.json"
    var idInt:Int?
    var commentOri:Int = 0
    var keyboardSize:CGSize?
    var alsoRepostButton:UIButton?
    var alseRepostBool = false
    var replyBool:Bool = false
    var commentID:Int?
    
    init(id: String,replyOrNot:Bool,commentID:Int) {
        super.init(id: id)
        replyBool = replyOrNot
        self.commentID = commentID
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.idInt = Int(self.id!)
        
        if replyBool == true {
            self.navigationBasicItem?.title = "Reply"
        }
        
        registerForKeyboardNotifications()
        
        setupAlsoRepostButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerForKeyboardNotifications(){
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NBWCommentViewController.keyboardWasShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NBWCommentViewController.keyboardWasHidden(_:)), name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func keyboardWasShow(notif:NSNotification){
        
        let info = notif.userInfo! as NSDictionary
        
        let value = info.objectForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
    
        self.keyboardSize = value.CGRectValue().size
        
//        print(self.keyboardSize!.height)
        
    }
    
    func keyboardWasHidden(notif:NSNotification){
        
        let info = notif.userInfo! as NSDictionary
        let value = info.objectForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        self.keyboardSize = value.CGRectValue().size
        
//        print(self.keyboardSize?.height)
    }
    
    func setupAlsoRepostButton(){
        
        self.alsoRepostButton = UIButton.init(frame: CGRect(x: 8, y: self.view.frame.height - 330, width: 150, height: 20))
        self.alsoRepostButton?.setTitle("  Also Repost", forState: .Normal)
        self.alsoRepostButton?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.alsoRepostButton?.titleLabel?.font = UIFont.systemFontOfSize(15)
        self.alsoRepostButton?.setImage(UIImage(named: "frame"), forState: .Normal)
        self.alsoRepostButton?.addTarget(self, action: #selector(NBWCommentViewController.alsoRepostOrNot), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(self.alsoRepostButton!)
    }
    
    override func sendTextViewContext() {
        super.sendTextViewContext()
        
        if replyBool {
            Alamofire.request(.POST, replyCommentURL, parameters: ["access_token":accessToken,"cid":commentID!,"id":idInt!,"comment":(self.textView?.text)!], encoding: ParameterEncoding.URL, headers: nil)
        }else{
            Alamofire.request(.POST, commentCreateURL, parameters: ["access_token":accessToken,"comment":(self.textView?.text)!,"id":self.idInt!,"comment_ori":self.commentOri], encoding: ParameterEncoding.URL, headers: nil)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func alsoRepostOrNot(){
        
        if self.alseRepostBool == false {
            self.alseRepostBool = true
            self.alsoRepostButton?.setImage(UIImage(named: "tick"), forState: .Normal)
            self.commentOri = 1
        }else{
            self.alseRepostBool = false
            self.alsoRepostButton?.setImage(UIImage(named: "frame"), forState: .Normal)
            self.commentOri = 0
        }
    }

}
