//
//  NBWBasicViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 2/17/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWBasicViewController: UIViewController {
    
    var id:String?
    var navigationBarHeight:CGFloat?
    var navigationBasicItem:UINavigationItem?
    var textView:UITextView?
    var toolBar:UIToolbar?
    
    
    //MARK: - Init
    init(id:String,navigationBarHeight:CGFloat){
        super.init(nibName: nil, bundle: nil)
        self.id = id
        self.navigationBarHeight = navigationBarHeight
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.whiteColor()
        
        setupNavigationBar()
        
        setupTextViewAndToolBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNavigationBar(){

        let navigationBar                            = UINavigationBar.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.navigationBarHeight!+20))

        self.navigationBasicItem                     = UINavigationItem.init(title: "Comment")

        self.navigationBasicItem!.leftBarButtonItem  = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("dismissViewController"))

        self.navigationBasicItem!.rightBarButtonItem = UIBarButtonItem.init(title: "Send", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("sendTextViewContext"))

        navigationBar.setItems([self.navigationBasicItem!], animated: true)
        navigationBar.tintColor                      = UIColor.orangeColor()
        
        self.view.addSubview(navigationBar)
    }
    
    
    
    func setupTextViewAndToolBar(){
        
        self.textView = UITextView.init(frame: CGRect(x: 8, y: self.navigationBarHeight!+20, width: self.view.frame.width - 16, height: self.view.frame.height - 100))

        self.toolBar  = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        
        self.textView?.inputAccessoryView = toolBar
        
        self.textView?.becomeFirstResponder()
        
        self.view.addSubview(self.textView!)
    }
    
    //MARK: - UIButton
    func dismissViewController(){
        
        self.textView?.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendTextViewContext(){
        
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
