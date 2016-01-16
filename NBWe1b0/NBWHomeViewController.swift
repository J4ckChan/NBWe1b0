//
//  NBWHomeViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 1/11/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit
import Alamofire

class NBWHomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let homeTimeline     = "https://api.weibo.com/2/statuses/home_timeline.json"
    let resuseIdentifier = "BasicCell"
    
    var cellCache:NSCache?
    var numberOfImageStackView:CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        self.tableView.dataSource = self
        self.tableView.delegate   = self
        
        cellCache = NSCache.init()
        
        numberOfImageStackView = 2
        
//        self.getHomeTimeline()
    }
    
    func getHomeTimeline(){
        Alamofire.request(.GET, homeTimeline, parameters: ["access_token":accessToken,"count":2], encoding:ParameterEncoding.URLEncodedInURL, headers: nil)
            .response { (request, response, data, error) -> Void in
                do{
                    let  json = try NSJSONSerialization.JSONObjectWithData(data!, options:.MutableContainers)
                    let statuesArray = json["statuses"]
                    print(statuesArray)
                }catch let error as NSError {
                    print("error: \(error.localizedDescription)")
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func weiboLogin(sender: UIBarButtonItem) {
        let request         = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = redirectURL
        request.scope       = "all"
        
        WeiboSDK.sendRequest(request)
    }
}

    //MARK: - UITableViewDataSource

extension NBWHomeViewController: UITableViewDataSource,  UITableViewDelegate, UINavigationBarDelegate{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let key:String = "\(indexPath.section)-\(indexPath.row)"
        
        var cell = self.cellCache?.objectForKey(key) as? NBWTableViewBasicCell
        
        if cell == nil {
            cell = tableView.dequeueReusableCellWithIdentifier(resuseIdentifier) as? NBWTableViewBasicCell
            configureHomeTableViewCell(cell!)
        }else {
            configureHomeTableViewCell(cell!)
        }
        
        
        return cell!
    }
    
    //HeightForRow
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if numberOfImageStackView > 0 {
            return 330.0
        }else{
            return 100.0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let key:String = "\(indexPath.section)-\(indexPath.row)"
        
        var cell = self.cellCache?.objectForKey(key) as?NBWTableViewBasicCell
        
        if cell == nil {
            cell = tableView.dequeueReusableCellWithIdentifier("BasicCell") as? NBWTableViewBasicCell
            cell = configureHomeTableViewCell(cell!)
            cellCache?.setObject(cell!, forKey: key)
        }
        
        let headerHeight:CGFloat = 40
        
        let bodyLabelHeight:CGFloat = (cell?.bodyTextLabel.frame.height)!
        
        let imageHeight:CGFloat = ((self.tableView.frame.width/3.0)-12)*numberOfImageStackView!
        
        let spacingHeight:CGFloat = 8
        
        let cellHeight = headerHeight + bodyLabelHeight + imageHeight + spacingHeight * 3 + 22+32
        
        print("The Height of Cell is: \(cellHeight)\n bodyLabelHeigt:\(bodyLabelHeight)\n imageHeight:\(imageHeight)")
        print(cell?.imageStackView.frame.height)
        
        return cellHeight
    }
    
    func configureHomeTableViewCell(cell:NBWTableViewBasicCell)-> NBWTableViewBasicCell {
        
        //Setup Header
        
        //Setup bodyTextLabel
        let text = "NSCache 一言蔽之是一个很傻瓜式的缓存控件，存取方式类似于NSDictionary，工作方式与苹果的内存管理体系相一致，在内存吃紧的时候，它会自动释放存储的对象。所以"
        
        cell.bodyTextLabel.text = text
        
        let labelText = cell.bodyTextLabel.text
        let labelTextNSString = NSString(CString:labelText!, encoding: NSUTF8StringEncoding)
        
//        cell.bodyTextLabel.backgroundColor = UIColor.lightGrayColor()
        
        let labelFont = UIFont.systemFontOfSize(17)
        let attributesDictionary = [NSFontAttributeName:labelFont]
        let labelSize = CGSize(width: self.tableView.frame.width-16, height:CGFloat.max)
        let options:NSStringDrawingOptions = [.UsesLineFragmentOrigin,.UsesFontLeading]
        
        let labelRect = labelTextNSString!.boundingRectWithSize(labelSize, options: options, attributes: attributesDictionary,context: nil)
        
        cell.bodyTextLabel.frame = labelRect
        
        //Setup ImageStackView
        configureImageStakView(cell)
        
        return cell
    }

    func configureImageStakView(cell:NBWTableViewBasicCell){
        
        if numberOfImageStackView == 1 {
            cell.imageViewOne.image   = UIImage(named: "cloud_1")
            cell.imageViewTwo.image   = UIImage(named: "cloud_2")
            cell.imageViewThree.image = UIImage(named: "cloud_3")
            cell.imageStack2.hidden   = true
            cell.imageStack3.hidden   = true
        }else if numberOfImageStackView == 2 {
            cell.imageViewOne.image   = UIImage(named: "cloud_1")
            cell.imageViewTwo.image   = UIImage(named: "cloud_2")
            cell.imageViewThree.image = UIImage(named: "cloud_3")
            cell.imageViewFour.image  = UIImage(named: "cloud_4")
            cell.imageViewFive.image  = UIImage(named: "cloud_5")
            cell.imageViewSix.image   = UIImage(named: "cloud_6")
            cell.imageStack3.hidden = true
        }else if numberOfImageStackView == 3{
            cell.imageViewOne.image   = UIImage(named: "cloud_1")
            cell.imageViewTwo.image   = UIImage(named: "cloud_2")
            cell.imageViewThree.image = UIImage(named: "cloud_3")
            cell.imageViewFour.image  = UIImage(named: "cloud_4")
            cell.imageViewFive.image  = UIImage(named: "cloud_5")
            cell.imageViewSix.image   = UIImage(named: "cloud_6")
            cell.imageViewSeven.image = UIImage(named: "cloud_7")
            cell.imageViewEight.image = UIImage(named: "cloud_8")
            cell.imageViewNine.image  = UIImage(named: "cloud_9")
        }else{
            cell.imageStackView.hidden = true
            cell.imageStack2.hidden    = true
            cell.imageStack3.hidden    = true
        }
    }
}
