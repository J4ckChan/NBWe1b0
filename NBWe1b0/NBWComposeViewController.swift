//
//  NBWComposeViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 1/12/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWComposeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let windowsFrame = UIScreen.mainScreen().bounds
        self.view.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        let blurEffect = UIBlurEffect(style:.Light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRectMake(0, 0, windowsFrame.width, windowsFrame.height - 45)
        self.view.addSubview(blurView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    @IBAction func writeText(sender: AnyObject) {
        
        let updateStatusVC = NBWUpdateStatusVC.init(compseVC: self)
        presentViewController(updateStatusVC, animated: true, completion: nil)
    }
    
    @IBAction func uploadPhoto(sender: AnyObject) {
    }
    
    @IBAction func checkIn(sender: AnyObject) {
    }
    
    @IBAction func closeCompose(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}