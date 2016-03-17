//
//  NBWCommentTableViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/3/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage

class NBWCommentTableViewController: UITableViewController {
    
    let commentToMeURLString = "https://api.weibo.com/2/comments/to_me.json"
    let commentCellIdentifier = "CommentCell"
    let replyCommentCellIdentifier = "ReplyCommentCell"
    var commentDelegateAndDataSource:NBWCommentArrayDelegateAndDataSource?
    
    var commentArray = [Comment]()
    var filterByAuthor = 0
    var midButton:UIButton?
    var midButtonTitle:String = "All Comments"
    var comment:Comment?
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = UIColor.lightGrayColor()
        
        setupMidBarButtonItem()
        
        let store = NBWCommentStore.init(urlString: commentToMeURLString, filterByAuthor: filterByAuthor)
        
        store.delegate = self
        
        commentArray = store.fetchDataFromCoreData()
        
        setupTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        managerContextSave()
    }
    
    func setupTableView(){
        self.tableView.registerNib(UINib.init(nibName: "NBWCommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        self.tableView.registerNib(UINib.init(nibName: "NBWReplyCommentCell", bundle: nil), forCellReuseIdentifier: "ReplyCommentCell")
        commentDelegateAndDataSource = NBWCommentArrayDelegateAndDataSource.init(comments: commentArray)
        self.tableView.delegate = commentDelegateAndDataSource
        self.tableView.dataSource = commentDelegateAndDataSource
        tableView.reloadData()
    }
    
    //MARK: - UIButton
    
    func setupMidBarButtonItem(){
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        midButton = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        midButton?.setTitle(midButtonTitle, forState: .Normal)
        midButton?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        midButton?.titleLabel?.font = UIFont.systemFontOfSize(15, weight: UIFontWeightBold)
        midButton?.addTarget(self, action: Selector("filterComments:"), forControlEvents: .TouchUpInside)
        view.addSubview(midButton!)
        
        navigationItem.titleView = view
    }
    
    func filterComments(sender:AnyObject){
        
        let filterCommentVC = NBWFilterCommentTableViewController.init()
        filterCommentVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        filterCommentVC.preferredContentSize = CGSize(width: 150, height: 120)
        filterCommentVC.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        filterCommentVC.indexDelegate = self
        
        let popover = filterCommentVC.popoverPresentationController
        popover?.sourceView = filterCommentVC.view
        popover?.sourceRect = CGRect(x: (view.frame.width/2), y: (navigationController?.navigationBar.frame.height)! - 10, width: 0, height: 0)
        popover?.delegate = self
        presentViewController(filterCommentVC, animated: true, completion: nil)
    }
    
    func replyComment(sender:AnyObject){
        let cell = sender.superview!!.superview as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let id = commentArray[(indexPath?.row)!].status!.id
        let commentID = commentArray[(indexPath?.row)!].idstr
        let commentVC = NBWCommentViewController.init(id: id!,replyOrNot:true,commentID:Int(commentID!)!)
        presentViewController(commentVC, animated: true, completion: nil)
    }
}

//MARK: - Delegates

extension NBWCommentTableViewController:UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}

extension NBWCommentTableViewController:SendIndexDelegate{
    func sendIndex(index: Int) {
        filterByAuthor = index
        setupTableView()
    }
}

extension NBWCommentTableViewController:FetchDataFromStoreDelegate{
    func fetchCommentFromWeb(commentArray: [Comment]) {
        self.commentArray = commentArray
        setupTableView()
    }
}
