//
//  NBWDiscoveryViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 5/7/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWDiscoveryViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    let urlStr = "http://s.weibo.com/?Refer=STopic_icon"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadRequest(urlStr)
    }
    
    func loadRequest(urlStr:String) -> () {
        let url = NSURL(string: urlStr)
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
