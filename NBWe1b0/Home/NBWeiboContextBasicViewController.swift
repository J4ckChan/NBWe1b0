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
    var id:String?
    var weiboStatusArray:[WeiboStatus]?
    var weiboStatus:WeiboStatus?
    var navigationBarHeight:CGFloat?
    var viewWidth:CGFloat?
    var viewHeight:CGFloat?
    
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
        
//        fetchDataFromCoreData()
        
        configureWeiboStatus()
        
    }

    func configureWeiboStatus(){
      
        //ScrollView & ContextView & Repost_Comment_like bar
        let scrollView = UIScrollView.init(frame: CGRect(x: 0, y: navigationBarHeight!, width: viewWidth!, height: viewHeight! - 42))
        scrollView.contentSize = CGSize(width: viewWidth!, height: 1.5 * viewHeight!)
        scrollView.backgroundColor = UIColor.grayColor()
        self.view.addSubview(scrollView)
        
        let repostCommentLikeBar = UIImageView.init(frame: CGRect(x: 0, y: viewHeight! - 42, width: viewWidth!, height: 42))
        repostCommentLikeBar.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(repostCommentLikeBar)
        
        
        //StatusView ( headerImageView & screenNameLabel & sourceLabel & bodyTextLabel & imageView )
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Core Data
    func fetchDataFromCoreData(){
        
        do{
            let request = NSFetchRequest(entityName: "WeiboStatus")
            request.predicate = NSPredicate(format: "id == \(self.id!)")
            
            self.weiboStatusArray = try managerContext!.executeFetchRequest(request) as? [WeiboStatus]
        
            self.weiboStatus = weiboStatusArray![0]
            
        }catch let error as NSError {
            print("Fetching error: \(error.localizedDescription)")
        }
        
    }
}
