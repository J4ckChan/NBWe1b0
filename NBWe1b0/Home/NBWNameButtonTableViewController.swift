//
//  NBWNameButtonTableViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 2/29/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

protocol SendTimelineURLStringDelegate{
    func sendHomeTimeline()
    func sendFrindsTimeline()
}

class NBWNameButtonTableViewController: UITableViewController {
    
    var nameButtonArray = ["Homepage","Friends Circle","Group Weibo"]
    var sendTimelineURLStringDelegate:SendTimelineURLStringDelegate?
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        view.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
           return nameButtonArray.count
        }else{
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1{
            return "My Group"
        }else{
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = nameButtonArray[indexPath.row]
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                sendTimelineURLStringDelegate?.sendHomeTimeline()
            }else if indexPath.row == 1 {
                sendTimelineURLStringDelegate?.sendFrindsTimeline()
            }else{
                
            }
        }else{
            
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
