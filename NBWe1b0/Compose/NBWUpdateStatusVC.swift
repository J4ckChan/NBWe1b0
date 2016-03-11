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
    let imageUploadURL = "https://upload.api.weibo.com/2/statuses/upload.json"
    let friendsURL = "https://api.weibo.com/2/friendships/friends.json"
    var friendsYouFollowArray = [WeiboUser]()
    
    var visibleNumber = 0
    var shareWithImagesArray = ["public","onlyMe","friendsCircle"]
    let shareButtonWidthArray:[CGFloat] = [68,86,116]
    
    var navigationBasicItem:UINavigationItem?
    var textView:UITextView?
    
    //ImageView
    var imageArray = [UIImage]()
    var imagePlaceHolderView:UIView?
    var imageViewHeight:CGFloat?
    var imageViewArray = Array.init(count: 6, repeatedValue: UIImageView())
    
    //AccessoryView
    var accessoryView:UIView?
    var locationButton:UIButton?
    var shareWithButton:UIButton?
    var numberOfWordsLabel:UILabel?
    var toolBar:UIToolbar?
    var textInitialLabel:UILabel?
    var rightButton:UIButton?
    
    init(imageArray:[UIImage]){
        super.init(nibName: nil, bundle: nil)
        self.imageArray = imageArray
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
        
        setupImagePlaceHolderView()
        
        setupImageView()
        
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
        rightButton?.addTarget(self, action: Selector("updateWeibo:"), forControlEvents: .TouchUpInside)
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
        
        textView = UITextView(frame: CGRect(x: 8, y: navigationBarHeight! + 28, width: view.frame.width - 16, height: 101))
        textView?.font = UIFont.systemFontOfSize(14)
        textView?.scrollEnabled = false
        textView?.becomeFirstResponder()
        textView?.delegate = self
        view.addSubview(textView!)
    }
    
    func setupImagePlaceHolderView(){
        
        imageViewHeight = (view.frame.width - 32)/3
        imagePlaceHolderView = UIView(frame: CGRect(x: 8, y: (textView?.frame.origin.y)! + (textView?.frame.size.height)! + 8, width: view.frame.width - 16, height: imageViewHeight! * 2 + 8))
        view.addSubview(imagePlaceHolderView!)
    }
    
    func setupImageView(){
        let count = CGFloat(imageArray.count)
        
        var k:CGFloat = 0
        for var i = 0; i < Int(count); i++ {
            var j:CGFloat = 0
            if i > 2 {
                j = 1
            }
            if j == 1 {
                k = CGFloat(i) - 3
            }
            imageViewArray[i] = UIImageView.init(frame: CGRect(x: k*(imageViewHeight! + 8), y: j*(imageViewHeight! + 8), width: imageViewHeight!, height: imageViewHeight!))
            imageViewArray[i].image = imageArray[i]
            let xImageView = UIImageView(frame: CGRect(x: imageViewHeight! - 20, y: 0, width: 20, height: 20))
            xImageView.image = UIImage(named: "x")
            imageViewArray[i].addSubview(xImageView)
            let tap = UITapGestureRecognizer.init(target: self, action: Selector("deleteThisPhoto:"))
            xImageView.addGestureRecognizer(tap)
            xImageView.userInteractionEnabled = true
            xImageView.tag = i
            imageViewArray[i].userInteractionEnabled = true
            imageViewArray[i].tag = i
            imagePlaceHolderView?.addSubview(imageViewArray[i])
            k++
        }
    }
    
    func setupAccessoryBar(){
        
        accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 72))
        accessoryView?.backgroundColor = UIColor.whiteColor()
        
        shareWithButton = UIButton(frame: CGRect(x: view.frame.width - shareButtonWidthArray[0] - 8, y: 0, width: shareButtonWidthArray[0], height: 20))
        shareWithButton!.setImage(UIImage(named: "public"), forState: .Normal)
        shareWithButton?.addTarget(self, action: Selector("shareWith:"), forControlEvents: .TouchUpInside)
        accessoryView?.addSubview(shareWithButton!)
        
        numberOfWordsLabel = UILabel(frame: CGRect(x: view.frame.width - (shareWithButton?.frame.width)! - 116, y: 0, width: 100, height: 20))
        numberOfWordsLabel!.text = "4 Words"
        numberOfWordsLabel?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightThin)
        numberOfWordsLabel?.textAlignment = NSTextAlignment.Right
        accessoryView?.addSubview(numberOfWordsLabel!)
        
        locationButton = UIButton(frame: CGRect(x: 8, y: 0, width: 100, height: 20))
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
    
    //MARK: - UIButton
    
    func shareWith(sender:AnyObject){
        let shareWithTVC = NBWShareWithTableVC.init()
        shareWithTVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        shareWithTVC.preferredContentSize = CGSize(width: 120, height: 90)
        shareWithTVC.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        shareWithTVC.delegate = self
        
        let popover = shareWithTVC.popoverPresentationController
        popover?.barButtonItem = sender as? UIBarButtonItem
        popover?.sourceView = shareWithTVC.view
        popover?.sourceRect = CGRect(x: (shareWithButton?.center.x)! , y: view.frame.height - 288, width: 0, height: 0)
        popover?.delegate = self
        presentViewController(shareWithTVC, animated: true, completion: nil)
    }
    
    func dismissVC(sender:AnyObject){
        textView?.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateWeibo(sender:AnyObject){
        
        if imageArray.count > 0 {
            let imageData = UIImageJPEGRepresentation(imageArray[0], 1)
            Alamofire.request(.POST, imageUploadURL, parameters: ["access_token":accessToken,"status":(textView?.text)!,"visible":visibleNumber,"pic":imageData!], encoding: ParameterEncoding.URL, headers: nil)
        }else{
            Alamofire.request(.POST, statusUpdateURL, parameters: ["access_token":accessToken,"status":(textView?.text)!,"visible":visibleNumber], encoding: ParameterEncoding.URL, headers: nil)
        }
        dismissVC(self)
    }
    
    func deleteThisPhoto(tap:UITapGestureRecognizer){
        let xImageView = tap.view as! UIImageView
        let imageView = xImageView.superview as! UIImageView
        let index = imageView.tag
        var originalFrame = imageView.frame
        var newFrame:CGRect?
        
        let count = imageArray.count

        imageArray[index] = UIImage.init()
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            imageView.removeFromSuperview()
            }) { (Bool) -> Void in
                if index != (count - 1) {
                    for var i = index, j = index + 1; j < count; i++, j++ {
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                        newFrame = self.imageViewArray[j].frame
                        self.imageViewArray[j].frame = originalFrame
                        originalFrame = newFrame!
                        }, completion: nil)
                    }
                }
        }
    }

    
    //MAKR: - UITabBarButton

    func fetchPhoto(){
        let uploadImageVC = NBWUploadImageCollectionViewController.init()
        uploadImageVC.imageDelegate = self
        let navigationVC = UINavigationController.init(rootViewController: uploadImageVC)
        presentViewController(navigationVC, animated: true, completion: nil)
    }
    
    func atFriends(){
        
        Alamofire.request(.GET, friendsURL, parameters: ["access_token":accessToken,"screen_name":"J4ck_Chan"], encoding: ParameterEncoding.URL, headers: nil)
            .responseJSON { (Response) -> Void in
                
                do {
                    
                    let friendJSONDict = try NSJSONSerialization.JSONObjectWithData(Response.data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                    
                    let friendsArray = friendJSONDict["users"] as! NSArray
                    
                    self.importUserData(friendsArray)
                    
                    let contactViewController = NBWContactTableViewController.init(contactArray: self.friendsYouFollowArray)
                    
                    contactViewController.sendScreenNameDelegate = self
                    
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
    
    //MARK: - CoreData
    func importUserData(friendsArray:NSArray){
        
        self.friendsYouFollowArray = []
        
        for userDict in friendsArray {
            
            let weiboUser = weiboUserManagedObject()
            
            importUserDataFromJSON(weiboUser, userDict: userDict as! NSDictionary)
            
            self.friendsYouFollowArray.append(weiboUser)
        }
    }
}

//MARK:- Delegate

extension NBWUpdateStatusVC:UITextViewDelegate{
    
    func textViewDidChange(textView: UITextView) {
        
        //label & button
        if textView.text.characters.count > 0 {
            navigationBasicItem?.rightBarButtonItem?.enabled = true
            rightButton?.setImage(UIImage(named: "send"), forState: .Normal)
            textInitialLabel?.text = ""
            let array = textView.text.componentsSeparatedByString(" ")
            if array.count > 140 {
                numberOfWordsLabel?.text = "-\(array.count - 140) Words"
                numberOfWordsLabel?.textColor = UIColor.redColor()
            }else{
                numberOfWordsLabel?.text = "\(array.count) Words"
            }
        }else{
            textInitialLabel?.text = "What's on your mind?"
            navigationBasicItem?.rightBarButtonItem?.enabled = false
            rightButton?.setImage(UIImage(named: "noSend"), forState: .Normal)
            numberOfWordsLabel?.text = "4 Words"
        }
        
        //textView & imageView
        let textNSString = textView.text as NSString
        let size = textView.frame.size
        let options: NSStringDrawingOptions = [.UsesLineFragmentOrigin,.UsesFontLeading]
        let rect = textNSString.boundingRectWithSize(size, options: options, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(14)], context: nil)
        
        if rect.size.height + 30 >= 100 {
            textView.frame.size.height = rect.size.height + 30
            
            let imageFrame = imagePlaceHolderView?.frame
            imagePlaceHolderView?.frame = CGRect(origin: CGPoint(x: 8, y: textView.frame.origin.y + textView.frame.size.height + 8), size: (imageFrame?.size)!)
        }
    }
    
}

extension NBWUpdateStatusVC:UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}

extension NBWUpdateStatusVC:SendIndexDelegate{
    func sendIndex(index: Int) {
        visibleNumber = index
        
        UIView.animateWithDuration(0.5) { () -> Void in
            self.shareWithButton?.setImage(UIImage(named: self.shareWithImagesArray[index]), forState: .Normal)
            self.shareWithButton?.frame = CGRect(x: self.view.frame.width - self.shareButtonWidthArray[index] - 8, y: 0, width: self.shareButtonWidthArray[index], height: 20)
            self.numberOfWordsLabel?.frame = CGRect(x: self.view.frame.width - self.shareButtonWidthArray[index] - 116, y: 0, width: 100, height: 20)
        }
    }
}

extension NBWUpdateStatusVC:SendScreenNameToTextViewDelegate {
    func sendScreenName(screenName: String) {
        self.textView?.text.appendContentsOf("@\(screenName) ")
    }
}

extension NBWUpdateStatusVC:SendImageToStatusVCDelegate {
    func sendImageToStatusVC(imageArray: [UIImage]) {
        dismissViewControllerAnimated(true, completion: nil)
        self.imageArray.removeAll()
        for image in imageArray {
            self.imageArray.append(image)
        }
        textView?.becomeFirstResponder()
        setupImageView()
    }
}
