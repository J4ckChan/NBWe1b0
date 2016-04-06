//
//  NBWSettingsController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 4/6/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWSettingsController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.title = "Settings"
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
        self.tableView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SettingCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 2
        }else if section == 3{
            return 1
        }else {
            return 3
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingCell", forIndexPath: indexPath)

        // Configure the cell...
        if indexPath.section == 3 {
            cell.textLabel?.text = "Log out current account"
            cell.textLabel?.textColor = UIColor.redColor()
        }else{
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    cell.textLabel?.text = "Accounts"
                }else{
                    cell.textLabel?.text = "Security"
                }
            }else if indexPath.section == 1 {
                if indexPath.row == 0 {
                    cell.textLabel?.text = "Notices"
                }else if indexPath.row == 1 {
                    cell.textLabel?.text = "Privacy"
                }else{
                    cell.textLabel?.text = "Settings"
                }
            }else{
                if indexPath.row == 0 {
                    cell.textLabel?.text = "Clear cache"
                }else if indexPath.row == 1 {
                    cell.textLabel?.text = "Feedback"
                }else{
                    cell.textLabel?.text = "About Weibo"
                }
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
}
