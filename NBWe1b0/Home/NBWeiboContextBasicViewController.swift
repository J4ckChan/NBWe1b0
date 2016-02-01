//
//  NBWeiboContextBasicViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 1/26/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage

class NBWeiboContextBasicViewController: UIViewController {
    
    
    //Weibo Status Data
    var id:String = ""
    var weiboStatusArray:[WeiboStatus]?
    var weiboStatus:WeiboStatus?
    var navigationBarHeight:CGFloat?
    var viewWidth:CGFloat?
    var viewHeight:CGFloat?
    
    //ImageView
    var imageView1: UIImageView?
    var imageView2: UIImageView?
    var imageView3: UIImageView?
    var imageView4: UIImageView?
    var imageView5: UIImageView?
    var imageView6: UIImageView?
    
    init(id:String){
        super.init(nibName: nil, bundle: nil)
        self.id = id
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Weibo Context"
        self.navigationController?.navigationBar.tintColor = UIColor.grayColor()
        self.navigationBarHeight = self.navigationController?.navigationBar.frame.height
        self.viewHeight = self.view.bounds.height
        self.viewWidth  = self.view.bounds.width
        
        fetchDataFromCoreData()
        
        configureWeiboStatus()
        
    }

    //Status Layout
    func configureWeiboStatus(){
      
        //ScrollView & ContextView & Repost_Comment_like bar
        let scrollView                       = UIScrollView.init(frame: CGRect(x: 0, y: 0, width: viewWidth!, height: viewHeight! - 42))
        scrollView.contentSize               = CGSize(width: viewWidth!, height: 1.5 * viewHeight!)
        scrollView.backgroundColor           = UIColor.lightGrayColor()
        self.view.addSubview(scrollView)

        let repostCommentLikeBar             = UIImageView.init(frame: CGRect(x: 0, y: viewHeight! - 42, width: viewWidth!, height: 42))
        repostCommentLikeBar.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(repostCommentLikeBar)
        
        
        //StatusView ( StatusView & headerImageView & screenNameLabel & sourceLabel & bodyTextLabel & imageView )
        let headerImageView                = UIImageView.init(frame: CGRect(x: 8, y: 8, width: 40, height: 40))
        headerImageView.sd_setImageWithURL(NSURL(string: (self.weiboStatus?.user?.avatar_large)!))
        headerImageView.clipsToBounds      = true
        headerImageView.layer.borderWidth  = 1
        headerImageView.layer.borderColor  = UIColor.lightGrayColor().CGColor
        headerImageView.layer.cornerRadius = 20

        let screenNameLable                = UILabel.init(frame: CGRect(x: 56, y: 8, width: 200, height: 20))
        screenNameLable.font               = UIFont.boldSystemFontOfSize(16)
        screenNameLable.text               = weiboStatus?.user?.screen_name
        screenNameLable.textColor          = UIColor.orangeColor()

        let sourceLabel                    = UILabel.init(frame: CGRect(x: 56, y: 28, width: 300, height: 20))
        sourceLabel.font                   = UIFont.systemFontOfSize(14)
        sourceLabel.text                   = weiboStatus?.source
        sourceLabel.textColor              = UIColor.lightGrayColor()

        let labelText                      = weiboStatus?.text
        let labelTextNSString              = NSString(CString: labelText!, encoding: NSUTF8StringEncoding)
        let labelFont                      = UIFont.systemFontOfSize(17)
        let attributeDictionary            = [NSFontAttributeName:labelFont]
        let labelSize                      = CGSize(width: self.view.frame.width - 16, height: CGFloat.max)
        let options:NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading]
        let labelRect                      = labelTextNSString?.boundingRectWithSize(labelSize, options: options, attributes: attributeDictionary, context: nil)

        let bodyTextLabel                  = UILabel(frame: CGRect(x: 8, y: 56, width: (labelRect?.width)!, height: (labelRect?.height)!))
        bodyTextLabel.numberOfLines        = 0
        bodyTextLabel.font                 = UIFont.systemFontOfSize(17, weight: UIFontWeightThin)
        bodyTextLabel.text                 = weiboStatus?.text
        
        var statusViewHeight:CGFloat = 0
        let bodyTextLabelHeight:CGFloat = bodyTextLabel.frame.height
        let picsCount = self.weiboStatus?.pics?.count
        let weiboStatusPicsSet = self.weiboStatus!.pics as! Set<WeiboStatusPics>
        
        let imageViewWidth:CGFloat = (self.view.frame.width - 32)/3.0
        
        if self.weiboStatus?.retweeted_status == nil {
            
            self.imageView1 = UIImageView.init(frame: CGRect(x: 8, y: 64 + bodyTextLabelHeight, width: imageViewWidth, height: imageViewWidth))
            self.imageView2 = UIImageView.init(frame: CGRect(x: 16 + imageViewWidth, y: 64 + bodyTextLabelHeight, width: imageViewWidth, height: imageViewWidth))
            self.imageView3 = UIImageView.init(frame: CGRect(x: 24 + imageViewWidth * 2, y: 64 + bodyTextLabelHeight, width: imageViewWidth, height: imageViewWidth))
            self.imageView4 = UIImageView.init(frame: CGRect(x: 8, y: 72 + bodyTextLabelHeight + imageViewWidth, width: imageViewWidth, height: imageViewWidth))
            self.imageView5 = UIImageView.init(frame: CGRect(x: 16 + imageViewWidth, y: 72 + bodyTextLabelHeight + imageViewWidth, width: imageViewWidth, height: imageViewWidth))
            self.imageView6 = UIImageView.init(frame: CGRect(x: 24 + imageViewWidth * 2, y: 72 + bodyTextLabelHeight + imageViewWidth, width: imageViewWidth, height: imageViewWidth))
            
            let imageViewArray = [self.imageView1,self.imageView2,self.imageView3,self.imageView4,self.imageView5,self.imageView6]
            
            if picsCount == 0 {
                
                statusViewHeight = 56 + bodyTextLabel.frame.height + 8
                
            }else if picsCount == 1 {
                
                self.imageView1?.frame.size = CGSize(width: 140, height: 105)
                
                self.imageView1!.sd_setImageWithURL(NSURL(string: (self.weiboStatus?.bmiddle_pic)!))
                self.imageView1!.contentMode = UIViewContentMode.ScaleAspectFit

                statusViewHeight             = 64 + bodyTextLabel.frame.height + imageView1!.frame.height + 8
                
            }else if picsCount == 2 || picsCount == 3 {
                
                var i = 0
                for weiboStatusPic in weiboStatusPicsSet {
                    imageViewArray[i]!.sd_setImageWithURL(NSURL(string:weiboStatusPic.pic! ))
                    i = i + 1
                }
                
               statusViewHeight = 64 + bodyTextLabelHeight + imageViewWidth + 8
                
            }else if picsCount == 4  {
            
                var i = 0
                for weiboStatusPic in weiboStatusPicsSet {
                    imageViewArray[i]!.sd_setImageWithURL(NSURL(string:weiboStatusPic.pic! ))
                    i = i + 1
                    if i == 2 {
                        i = i + 1
                    }
                }
                
                statusViewHeight = 64 + bodyTextLabelHeight + imageViewWidth * 2 + 16
                
            }else if picsCount > 4 {
                
                var i = 0
                for weiboStatusPic in weiboStatusPicsSet {
                    imageViewArray[i]!.sd_setImageWithURL(NSURL(string:weiboStatusPic.pic!))
                    i = i + 1
                    if i > 5 {
                        break
                    }
                }
                
                statusViewHeight = 64 + bodyTextLabelHeight + imageViewWidth * 2 + 16
                
            }
            
            let statusView = UIView.init(frame: CGRect(x: 0, y: 0, width: viewWidth!, height: statusViewHeight))
            
            scrollView.addSubview(statusView)
            statusView.addSubview(headerImageView)
            statusView.addSubview(screenNameLable)
            statusView.addSubview(sourceLabel)
            statusView.addSubview(bodyTextLabel)
            statusView.backgroundColor = UIColor.whiteColor()
            
            if picsCount == 1 {
                
                statusView.addSubview(self.imageView1!)
                
            }else if picsCount == 2 || picsCount == 3 {
                
                for var i = 0; i < picsCount; i++ {
                    statusView.addSubview(imageViewArray[i]!)
                }
                
            }else if picsCount == 4 {
                
                for var i = 0; i < 5; i++ {
                    if i != 2 {
                       statusView.addSubview(imageViewArray[i]!)
                    }
                }
                
            }else if picsCount > 4 {
                
                for var i = 0; i < 6; i++ {
                    statusView.addSubview(imageViewArray[i]!)
                }
            }
        }
        
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Core Data
    func fetchDataFromCoreData(){
        
        do{
            let request = NSFetchRequest(entityName: "WeiboStatus")
            request.predicate = NSPredicate(format: "id == \(self.id)")
            
            self.weiboStatusArray = try managerContext!.executeFetchRequest(request) as? [WeiboStatus]
        
            self.weiboStatus = weiboStatusArray![0]
            
        }catch let error as NSError {
            print("Fetching error: \(error.localizedDescription)")
        }
        
    }
}
