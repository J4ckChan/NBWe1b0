//
//  NBWHomeViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 1/11/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

var viewWidth:CGFloat?
var viewHeight:CGFloat?
var navigationBarHeight:CGFloat?

class NBWHomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userNameButton: UIButton!
    
    let timelineURLs = ["https://api.weibo.com/2/statuses/home_timeline.json","https://api.weibo.com/2/statuses/bilateral_timeline.json"]
    var timelineURL               = "https://api.weibo.com/2/statuses/home_timeline.json"
    
    var refreshHeaderController:UIRefreshControl?
//    var refreshFooterController:UIRefreshControl?
    var weiboStatusesArray = [WeiboStatus]()
    var searchController:UISearchController?
    var nameButtonViewBool = false
    var nameButtonView:UIView?
    var nameButtonBackgroundImageView:UIImageView?
    var nameButtonBackgroundArrowImageView:UIImageView?
    var nameButtonTableViewController:NBWNameButtonTableViewController?
    var homeDelegateAndDataSource:NBWHomeDelegateAndDataSource?
    var store:NBWHomeStore?
    var backToTopButton:UIButton?
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        viewWidth = self.view.frame.width
        viewHeight = self.view.frame.height
        navigationBarHeight = self.navigationController?.navigationBar.frame.height

        //CoreData
    
        setupUserNameButton()
        setUpRefresh()
        setupStore()
        setupTableViewDelegateAndDataSource()
        setupButtonToTop()
    }
    
    override func viewWillDisappear(animated: Bool) {
        backToTopButton?.hidden = true
    }
    
    func setUpRefresh(){
        //HeaderRefresh
        self.refreshHeaderController = UIRefreshControl.init()
        self.tableView.addSubview(self.refreshHeaderController!)
        self.refreshHeaderController?.tintColor = UIColor.orangeColor()
        let attributedStrDict = [NSForegroundColorAttributeName:UIColor.orangeColor()]
        self.refreshHeaderController?.attributedTitle = NSAttributedString.init(string: "Refresh Data", attributes: attributedStrDict)
        
        self.refreshHeaderController!.addTarget(self.store, action: #selector(NBWHomeViewController.setupStore), forControlEvents: .ValueChanged)
        self.refreshHeaderController?.beginRefreshing()
    }
    
    func setupStore(){
        store = NBWHomeStore.init(urlString: timelineURL)
        store!.delegate = self
    }
    
    func setupTableViewDelegateAndDataSource(){
        homeDelegateAndDataSource = NBWHomeDelegateAndDataSource.init(array: weiboStatusesArray)
        self.tableView.dataSource = homeDelegateAndDataSource
        self.tableView.delegate   = homeDelegateAndDataSource
        self.tableView?.registerNib(UINib.init(nibName:"NBWTableViewBasicCell", bundle: nil), forCellReuseIdentifier: basicReuseIdentifier)
        self.tableView?.registerNib(UINib.init(nibName:"NBWTableViewImageCell", bundle: nil), forCellReuseIdentifier: multiImageReuseIdentifier)
        self.tableView?.registerNib(UINib.init(nibName:"NBWTableViewRepostCell", bundle: nil), forCellReuseIdentifier: repostReuseIdentifier)
        homeDelegateAndDataSource?.delegate = self
        homeDelegateAndDataSource?.showButtonDelegate = self
        tableView.reloadData()
    }
    
    func setupUserNameButton(){
        self.userNameButton.setTitle(userScreenName, forState: .Normal)
        self.userNameButton.addTarget(self, action: #selector(NBWHomeViewController.showNameButtonView(_:)), forControlEvents: .TouchUpInside)
    }
    
    func setupButtonToTop(){
        backToTopButton = UIButton(frame: CGRect(x: viewWidth! - 60, y: viewHeight! - (self.tabBarController?.tabBar.frame.size.height)! - 50, width: 40, height: 40))
        backToTopButton?.setImage(UIImage(named: "topButton"), forState: UIControlState.Normal)
        backToTopButton?.addTarget(self, action: #selector(scrollToTop(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        backToTopButton?.hidden = true
        self.tabBarController?.view.addSubview(backToTopButton!)
    }
    
    
    
    //MARK: - ButtonAction
    @IBAction func weiboLogin(sender: UIBarButtonItem) {
        let request         = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = redirectURL
        request.scope       = "all"
        
        WeiboSDK.sendRequest(request)
    }
    
    func showNameButtonView(sender:AnyObject){
        let nameButtonTableVC = NBWNameButtonTableViewController.init()
        nameButtonTableVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        nameButtonTableVC.preferredContentSize = CGSize(width: 160, height: 200)
        nameButtonTableVC.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        nameButtonTableVC.indexDelegate = self
        
        let popover = nameButtonTableVC.popoverPresentationController
        popover?.sourceView = nameButtonTableVC.view
        popover?.sourceRect = CGRect(x: userNameButton.center.x, y: userNameButton.center.y + userNameButton.frame.height/2, width: 0, height: 0)
        popover?.delegate = self
        presentViewController(nameButtonTableVC, animated: true, completion: nil)
    }
    
    func scrollToTop(sender:UIButton){
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        backToTopButton?.hidden = true
    }
}

//MARK: - UIPopoverPresentationControllerDelegate
extension NBWHomeViewController:UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}

//MARK: - Send TimelineURL 
extension NBWHomeViewController:SendIndexDelegate {
    func sendIndex(index:Int){
        timelineURL = timelineURLs[index]
        setupStore()
    }
}

//MARK: - FetchDataFromStoreDelegate
extension NBWHomeViewController:FetchDataFromStoreDelegate{
    func fetchDataFromWeb(array: [AnyObject]) {
        self.weiboStatusesArray = array as! [WeiboStatus]
        setupTableViewDelegateAndDataSource()
        self.refreshHeaderController?.endRefreshing()
    }
}

//MARK: - PushViewControllerDelegate
extension NBWHomeViewController:PushViewControllerDelegate{
    func pushViewController(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension NBWHomeViewController:ShowScrollToTopButton{
    func showButton() {
        backToTopButton?.hidden = false
    }
}

