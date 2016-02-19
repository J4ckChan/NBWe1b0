//
//  NBWBasicViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 2/17/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class NBWBasicViewController: UIViewController {
    
    let friendsURL = "https://api.weibo.com/2/friendships/friends.json"
    var friendsYouFollowArray = [WeiboUser]()
    
    var id:String?
    var navigationBarHeight:CGFloat?
    var navigationBasicItem:UINavigationItem?
    var textView:UITextView?
    var toolBar:UIToolbar?
    
    
    //MARK: - Init
    init(id:String,navigationBarHeight:CGFloat){
        super.init(nibName: nil, bundle: nil)
        self.id = id
        self.navigationBarHeight = navigationBarHeight
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.whiteColor()
        
        setupNavigationBar()
        
        setupTextViewAndToolBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNavigationBar(){

        let navigationBar                            = UINavigationBar.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.navigationBarHeight!+20))

        self.navigationBasicItem                     = UINavigationItem.init(title: "Comment")

        self.navigationBasicItem!.leftBarButtonItem  = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("dismissViewController"))

        self.navigationBasicItem!.rightBarButtonItem = UIBarButtonItem.init(title: "Send", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("sendTextViewContext"))

        navigationBar.setItems([self.navigationBasicItem!], animated: true)
        navigationBar.tintColor                      = UIColor.orangeColor()
        
        self.view.addSubview(navigationBar)
    }
    
    
    
    func setupTextViewAndToolBar(){
        
        self.textView = UITextView.init(frame: CGRect(x: 8, y: self.navigationBarHeight!+20, width: self.view.frame.width - 16, height: self.view.frame.height - 100))
        
        self.textView?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightThin)

        self.toolBar  = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))

        let flexibleSpaceButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)

        let photoButtonItem         = UIBarButtonItem.init(image: UIImage(named: "photo48"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("fetchPhoto"))

        let atButtonItem            = UIBarButtonItem.init(image: UIImage(named: "at48"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("atFriends"))

        let linkButtonItem          = UIBarButtonItem.init(image: UIImage(named: "link48"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("link"))

        let emojiButtonItem         = UIBarButtonItem.init(image: UIImage(named: "emoji48"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("sendEmoji"))

        let addButtonItem           = UIBarButtonItem.init(image: UIImage(named: "add48"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("add"))

        self.toolBar?.items         = [flexibleSpaceButtonItem,photoButtonItem,flexibleSpaceButtonItem,atButtonItem,flexibleSpaceButtonItem,linkButtonItem,flexibleSpaceButtonItem,emojiButtonItem,flexibleSpaceButtonItem,addButtonItem,flexibleSpaceButtonItem]
        
        self.toolBar?.tintColor = UIColor.lightGrayColor()
        
        self.textView?.inputAccessoryView = toolBar
        
        self.textView?.becomeFirstResponder()
        
        self.view.addSubview(self.textView!)
    }
    
    //MARK: - UIBarButtonItem
    func dismissViewController(){
        
        self.textView?.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendTextViewContext(){
        
    }
    
    func fetchPhoto(){
       
        let imagePicker = UIImagePickerController.init()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            imagePicker.sourceType = .Camera
        }else{
            imagePicker.sourceType = .PhotoLibrary
        }
        
        imagePicker.delegate = self
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    func atFriends(){
       
        Alamofire.request(.GET, friendsURL, parameters: ["access_token":accessToken,"screen_name":"J4ck_Chan"], encoding: ParameterEncoding.URL, headers: nil)
        .responseJSON { (Response) -> Void in

            do {
             
                let friendJSONDict = try NSJSONSerialization.JSONObjectWithData(Response.data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                
                let friendsArray = friendJSONDict["users"] as! NSArray
                
                self.importUserData(friendsArray)
                
                let contactViewController = NBWContactTableViewController.init(contactArray: self.friendsYouFollowArray)
                
                let navigationController = UINavigationController.init(rootViewController: contactViewController)
                
                self.presentViewController(navigationController, animated: true, completion: nil)
                
            }catch let error as NSError{
                
                print("Fetching Data:\(error.localizedDescription)")
            }
        }
    }
    
    func link(){
        
    }
    
    func sendEmoji(){
        
    }
    
    func add(){
        
    }
    
    //MARK:- Data
    func importUserData(friendsArray:NSArray){
        
        for userDict in friendsArray {
            
            let userEntity = NSEntityDescription.entityForName("WeiboUser", inManagedObjectContext: managerContext!)
            let weiboUser = NSManagedObject(entity: userEntity!, insertIntoManagedObjectContext: managerContext!) as! WeiboUser
            
            weiboUser.id                 = userDict["id"] as? NSNumber
            weiboUser.idstr              = userDict["idstr"] as? String
            weiboUser.screen_name        = userDict["screen_name"] as? String
            weiboUser.name               = userDict["name"] as? String
            weiboUser.province           = userDict["province"] as? NSNumber
            weiboUser.city               = userDict["city"] as? NSNumber
            weiboUser.location           = userDict["location"] as? String
            weiboUser.user_description   = userDict["description"] as? String
            weiboUser.url                = userDict["url"] as? String
            weiboUser.profile_image_url  = userDict["profile_image_url"] as? String
            weiboUser.profile_url        = userDict["profile_url"] as? String
            weiboUser.domain             = userDict["domain"] as? String
            weiboUser.weihao             = userDict["weihao"] as? String
            weiboUser.gender             = userDict["gender"] as? String
            weiboUser.followers_count    = userDict["followers_count"] as? NSNumber
            weiboUser.friends_count      = userDict["friends_count"] as? NSNumber
            weiboUser.statuses_count     = userDict["statuses_count"] as? NSNumber
            weiboUser.favourites_count   = userDict["favourites_count"] as? NSNumber
            weiboUser.created_at         = userDict["created_at"] as? String
            weiboUser.following          = userDict["following"] as? NSNumber
            weiboUser.allow_all_act_msg  = userDict["allow_all_act_msg"] as? NSNumber
            weiboUser.geo_enabled        = userDict["geo_enabled"] as? NSNumber
            weiboUser.verified           = userDict["verified"] as? NSNumber
            weiboUser.verified_type      = userDict["verified_type"] as? NSNumber
            weiboUser.remark             = userDict["remark"] as? String
            weiboUser.allow_all_comment  = userDict["allow_all_comment"] as? NSNumber
            weiboUser.avatar_large       = userDict["avatar_large"] as? String
            weiboUser.avatar_hd          = userDict["avatar_hd"] as? String
            weiboUser.verified_reason    = userDict["verified_reason"] as? String
            weiboUser.follow_me          = userDict["follow_me"] as? NSNumber
            weiboUser.online_status      = userDict["online_status"] as? NSNumber
            weiboUser.bi_followers_count = userDict["bi_followers_count"] as? NSNumber
            weiboUser.lang               = userDict["lang"] as? String
            
            self.friendsYouFollowArray.append(weiboUser)
        }
    }
}

extension NBWBasicViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
    }
}
