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

    @IBOutlet weak var weiboContextScrollView: UIScrollView!
    @IBOutlet weak var weiboContextContextView: UIView!
    
    //Status View
    @IBOutlet weak var weiboContextStatusView: UIView!
    @IBOutlet weak var weiboContextHeaderImageView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var bodyTextLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    //Repost Comment Like TableViewCell
    
    
    //bottom
    @IBOutlet weak var bottomImageView: UIImageView!
    
    
    //Weibo Status Data
    var id:String?
    var weiboStatusArray:[WeiboStatus]?
    var weiboStatus:WeiboStatus?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Weibo Context"
        self.navigationController?.navigationBar.tintColor = UIColor.grayColor()
        
        fetchDataFromCoreData()
        
        configureStatusInContextView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureStatusInContextView(){
        
        //header
        self.weiboContextHeaderImageView.sd_setImageWithURL(NSURL(string: (self.weiboStatus?.user?.avatar_large)!))
        self.weiboContextHeaderImageView.clipsToBounds = true
        self.weiboContextHeaderImageView.layer.borderWidth = 1.0
        self.weiboContextHeaderImageView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.weiboContextHeaderImageView.layer.cornerRadius = 20
        
        self.screenNameLabel.text = self.weiboStatus?.user?.screen_name
        self.sourceLabel.text = self.weiboStatus?.source
        
        //bodyTextLabel & image
        self.bodyTextLabel.text = self.weiboStatus?.text
        
        if self.weiboStatus?.bmiddle_pic != nil {
            self.imageView.sd_setImageWithURL(NSURL(string: (self.weiboStatus?.bmiddle_pic)!))
        }else{
            self.imageView.removeFromSuperview()
        }
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
