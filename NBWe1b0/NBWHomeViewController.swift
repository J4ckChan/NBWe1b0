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
    
    
    let homeTimeline = "https://api.weibo.com/2/statuses/home_timeline.json"
    
    var cellHeight:CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        self.tableView.dataSource = self
        self.tableView.delegate   = self
        
        self.getHomeTimeline()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("BasicCell", forIndexPath: indexPath) as! NBWTableViewBasicCell
        
        let text = "第二条意味着通过便利构造器和访问器间接得到对象，实际上没有获得对象的所有权，不需要负责对象的释放，只有通过alloc，retain，copy等手段得到的对象，才拥有对象的所有权，所以不要对通过便利构造器和访问器得到的对象进行release"
        
        cell.bodyTextLabel.text = text
        let labelText = cell.bodyTextLabel.text
        
        cell.bodyTextLabel.backgroundColor = UIColor.grayColor()
        
        cell.bodyTextLabel.font = UIFont.systemFontOfSize(17)
        cell.bodyTextLabel.numberOfLines = 0
        cell.bodyTextLabel.lineBreakMode = .ByCharWrapping
        
        let constraint = CGSize(width: cell.bodyTextLabel.frame.width, height:CGFloat.max)
        
        let labelTextNSString = NSString(CString:labelText!, encoding: NSUTF8StringEncoding)
        
        let labelSize = labelTextNSString!.boundingRectWithSize(constraint, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: nil,context: nil)
        
        cell.bodyTextLabel.frame = labelSize
        
        print("......\(cell.bodyTextLabel.frame.height)")
        
        return cell
    }
    
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let height1:CGFloat = 54
//        
//        let cell = tableView.dequeueReusableCellWithIdentifier("BasicCell") as! NBWTableViewBasicCell
//        
//        let text = "第二条意味着通过便利构造器和访问器间接得到对象，实际上没有获得对象的所有权，不需要负责对象的释放，只有通过alloc，retain，copy等手段得到的对象，才拥有对象的所有权，所以不要对通过便利构造器和访问器得到的对象进行release"
//        
//        cell.bodyTextLabel.text = text
//        let labelText = cell.bodyTextLabel.text
//        
//        cell.bodyTextLabel.backgroundColor = UIColor.grayColor()
//        
//        cell.bodyTextLabel.font = UIFont.systemFontOfSize(17)
//        cell.bodyTextLabel.numberOfLines = 0
//        cell.bodyTextLabel.lineBreakMode = .ByCharWrapping
//        
//        let constraint = CGSize(width: cell.bodyTextLabel.frame.width, height:9999)
//        let labelSize = labelText!.boundingRectWithSize(constraint, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: nil,context: nil)
//        
//        cell.bodyTextLabel.frame = labelSize
//        
//        print("......\(cell.bodyTextLabel.frame.height)")
//        
//        let height = cell.bodyTextLabel.frame.height + height1
//        
//        print("height:\(height)")
//        
//        return height
//    }
}
