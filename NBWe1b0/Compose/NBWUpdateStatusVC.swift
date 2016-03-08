//
//  NBWUpdateStatusVC.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/7/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit
import Alamofire

class NBWUpdateStatusVC: UIViewController {
    
    let statusUpdateURL = "https://api.weibo.com/2/statuses/update.json"
    var visibleNumber = 0
    
    var navigationBasicItem:UINavigationItem?
    var textView:UITextView?
    
    //AccessoryView
    var accessoryView:UIView?
    var locationButton:UIButton?
    var shareWithButton:UIButton?
    var numberOfWordsLabel:UILabel?
    var toolBar:UIToolbar?
    var textInitialLabel:UILabel?
    var rightButton:UIButton?
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.whiteColor()

        setupNavigationBar()
        
        setupTextView()
        
        setupAccessoryBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNavigationBar(){
        
        let navigationBar                       = UINavigationBar.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: navigationBarHeight!+20))
        
        navigationBasicItem                     = UINavigationItem.init(title: "NewWeibo")
        
        navigationBasicItem!.leftBarButtonItem  = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("dismissVC:"))
        
        let rightBarButtonContextView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 20))
        rightButton = UIButton(frame: rightBarButtonContextView.frame)
        rightButton!.setImage(UIImage(named: "noSend"), forState: .Normal)
        rightBarButtonContextView.addSubview(rightButton!)

        navigationBasicItem?.rightBarButtonItem = UIBarButtonItem.init(customView: rightBarButtonContextView)
        navigationBasicItem?.rightBarButtonItem?.enabled = false
        
        navigationBar.tintColor = UIColor.lightGrayColor()
        navigationBar.setItems([navigationBasicItem!], animated: true)
     
        
        view.addSubview(navigationBar)
    }
    
    func setupTextView(){
        
        textInitialLabel = UILabel(frame: CGRect(x: 12, y: navigationBarHeight! + 35, width: view.frame.width - 16, height: 20))
        textInitialLabel?.text = "What's on your mind?"
        textInitialLabel?.textColor = UIColor.lightGrayColor()
        view.addSubview(textInitialLabel!)
        
        textView = UITextView(frame: CGRect(x: 8, y: navigationBarHeight! + 28, width: view.frame.width - 16, height: view.frame.height - navigationBarHeight!-20))
        textView?.font = UIFont.systemFontOfSize(17)
        textView?.backgroundColor = UIColor.clearColor()
        textView?.becomeFirstResponder()
        textView?.delegate = self
        view.addSubview(textView!)
    }
    
    func setupAccessoryBar(){
        
        accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 72))
        
        shareWithButton = UIButton(frame: CGRect(x: view.frame.width - 68, y: 0, width: 60, height: 20))
        shareWithButton!.setImage(UIImage(named: "shareWith"), forState: .Normal)
        accessoryView?.addSubview(shareWithButton!)
        
        numberOfWordsLabel = UILabel(frame: CGRect(x: view.frame.width - 86, y: 0, width: 10, height: 20))
        numberOfWordsLabel!.text = "4"
        accessoryView?.addSubview(numberOfWordsLabel!)
        
        locationButton = UIButton(frame: CGRect(x: 8, y: 0, width: view.frame.width - (shareWithButton?.frame.origin.x)!, height: 20))
        locationButton?.setImage(UIImage(named: "addLocation"), forState: .Normal)
        accessoryView?.addSubview(locationButton!)
        
        toolBar  = UIToolbar.init(frame: CGRect(x: 0, y: 28, width: self.view.frame.width, height: 44))
        
        let flexibleSpaceButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let photoButtonItem         = UIBarButtonItem.init(image: UIImage(named: "photo48"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("fetchPhoto"))
        
        let atButtonItem            = UIBarButtonItem.init(image: UIImage(named: "at48"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("atFriends"))
        
        let linkButtonItem          = UIBarButtonItem.init(image: UIImage(named: "link48"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("link"))
        
        let emojiButtonItem         = UIBarButtonItem.init(image: UIImage(named: "emoji48"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("sendEmoji"))
        
        let addButtonItem           = UIBarButtonItem.init(image: UIImage(named: "add48"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("add"))
        
        toolBar?.items         = [flexibleSpaceButtonItem,photoButtonItem,flexibleSpaceButtonItem,atButtonItem,flexibleSpaceButtonItem,linkButtonItem,flexibleSpaceButtonItem,emojiButtonItem,flexibleSpaceButtonItem,addButtonItem,flexibleSpaceButtonItem]
        
        toolBar?.tintColor = UIColor.lightGrayColor()
        
        accessoryView?.addSubview(toolBar!)
        
        textView?.inputAccessoryView = accessoryView
    }
    
    func dismissVC(sender:AnyObject){
        textView?.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateWeibo(sender:AnyObject){
        Alamofire.request(.POST, statusUpdateURL, parameters: ["access_token":accessToken,"status":(textView?.text)!,"visible":visibleNumber], encoding: ParameterEncoding.URL, headers: nil)
    }
}

extension NBWUpdateStatusVC:UITextViewDelegate{
    
    func textViewDidChange(textView: UITextView) {
        if textView.text.characters.count > 0 {
            navigationBasicItem?.rightBarButtonItem?.enabled = true
            rightButton?.setImage(UIImage(named: "send"), forState: .Normal)
            textInitialLabel?.text = ""
        }else{
            textInitialLabel?.text = "What's on your mind?"
            navigationBasicItem?.rightBarButtonItem?.enabled = false
            rightButton?.setImage(UIImage(named: "noSend"), forState: .Normal)
        }
    }
    
}
