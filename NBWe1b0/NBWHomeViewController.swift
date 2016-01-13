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
    
    let homeTimeline = "https://api.weibo.com/2/statuses/home_timeline.json"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
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
