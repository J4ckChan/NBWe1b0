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
    var alsoCommentButton:UIButton?
    var alsoCommentBool = false
    
    override init(id: String, navigationBarHeight: CGFloat) {
        super.init(id: id, navigationBarHeight: navigationBarHeight)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationBasicItem?.title = "Repost"
        
        
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
