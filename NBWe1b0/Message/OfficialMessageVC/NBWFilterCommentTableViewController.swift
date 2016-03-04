//
//  NBWFilterCommentTableViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/4/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWFilterCommentTableViewController: UITableViewController {
    
    let filterCommentArray = ["All Comments","Following","Mine"]
    var indexDelegate:SendIndexDelegate?
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "filterCommentsCell")
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filterCommentArray.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("filterCommentsCell", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = filterCommentArray[indexPath.row]
        cell.textLabel?.font = UIFont.systemFontOfSize(15, weight: UIFontWeightBold)
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.textLabel?.textColor = UIColor.orangeColor()
        
        if indexPath.row == 0 && indexPath.row == 1 && indexPath.row == 2{
            indexDelegate?.sendIndex(indexPath.row)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}
