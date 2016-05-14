//
//  NBWTabBarController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 1/9/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWTabBarController: UITabBarController {
    
    var composeVC:NBWComposeViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delegate = self
        tabBar.tintColor = UIColor.orangeColor()
        
        // TabBarItem --- Compose
        let imageViewOriginX = 2.0*(self.tabBar.frame.size.width/5.0)
        let itemFrame = CGRectMake(imageViewOriginX, 0, tabBar.frame.size.width/5.0, tabBar.frame.size.height)
        
        let composeButton = UIButton(frame: itemFrame)
        composeButton.setImage(UIImage(named: "tabbar_compose_bg"), forState: .Normal)
        composeButton.addTarget(self, action: #selector(NBWTabBarController.presentComposeVC(_:)), forControlEvents: .TouchUpInside)
        tabBar.addSubview(composeButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentComposeVC(sender:AnyObject){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let composeVC = mainStoryboard.instantiateViewControllerWithIdentifier("ComposeViewController") as! NBWComposeViewController
        composeVC.delegate = self
        self.presentViewController(composeVC, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

    //MARK: - UITabBarControllerDelegate

extension NBWTabBarController:UITabBarControllerDelegate{
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        if viewController.isEqual(tabBarController.viewControllers![2]){
            return false
        }else{
            return true
        }
        
        
    }
}

extension NBWTabBarController:CloseSelfOpenNewViewControllerDelegate{
    func closeSelfOpenNewVC(option: composeOptions,_ imageArray:[UIImage]) {
        dismissViewControllerAnimated(false) { () -> Void in
            switch option{
            case .updateStatusVC:
                let updateStatusVC = NBWUpdateStatusVC.init(imageArray: imageArray)
                self.presentViewController(updateStatusVC, animated: true, completion: nil)
            case .uploadImageVC:
                let uploadImageVC = NBWUploadImageCollectionViewController.init()
                uploadImageVC.delegate = self
                let navigationVC = UINavigationController.init(rootViewController: uploadImageVC)
                self.presentViewController(navigationVC, animated: true, completion: nil)
            case .CheckInVC:
                print("CheckINvc")
            }
        }
    }
}
