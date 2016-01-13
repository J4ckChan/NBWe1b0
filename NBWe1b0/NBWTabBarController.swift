//
//  NBWTabBarController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 1/9/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.delegate = self
        self.tabBar.tintColor = UIColor.orangeColor()
        
        // TabBarItem --- Compose
        let addBackgroundImage = UIImage(named: "tabbar_compose_bg")
        let imageViewOriginX = 2.0*(self.tabBar.frame.size.width/5.0)
        
        let addImageView = UIImageView.init(frame: CGRectMake(imageViewOriginX, 0, self.tabBar.frame.size.width/5.0, self.tabBar.frame.size.height))
        addImageView.image = addBackgroundImage
        addImageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.tabBar.insertSubview(addImageView, atIndex: 1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let composeVC = mainStoryboard.instantiateViewControllerWithIdentifier("ComposeViewController")
            self.presentViewController(composeVC, animated: true, completion: nil)
        }
        return true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController){
        
    }
}
