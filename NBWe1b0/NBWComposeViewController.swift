//
//  NBWComposeViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 1/12/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

protocol CloseSelfOpenNewViewControllerDelegate{
    func closeSelfOpenNewVC(option:composeOptions,_ imageArray:[UIImage])
}

enum composeOptions {
    case updateStatusVC,uploadImageVC,CheckInVC
}

class NBWComposeViewController: UIViewController {
    
    var delegate:CloseSelfOpenNewViewControllerDelegate?
    var sendOption:composeOptions = .updateStatusVC
    var imageArray = [UIImage]()
    
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
        sendOption = .updateStatusVC
        delegate?.closeSelfOpenNewVC(sendOption,imageArray)
    }
    
    @IBAction func uploadPhoto(sender: AnyObject) {
        sendOption = .uploadImageVC
        delegate?.closeSelfOpenNewVC(sendOption,imageArray)
    }
    
    @IBAction func checkIn(sender: AnyObject) {
        sendOption = .CheckInVC
        delegate?.closeSelfOpenNewVC(sendOption,imageArray)
    }
    
    @IBAction func closeCompose(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}