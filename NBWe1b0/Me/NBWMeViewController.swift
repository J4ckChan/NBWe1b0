//
//  NBWMeViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/21/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWMeViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.title = "Me"
        self.tableView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        self.tableView.registerNib(UINib.init(nibName: "NBWMeTopTableViewCell", bundle: nil), forCellReuseIdentifier: "MeTopCell")
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MeCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 7
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 || section == 1 || section == 5 || section == 6 {
            return 1
        }else if section == 3 || section == 4{
            return 2
        }else{
            return 3
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 143
        }else{
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
           let cell = tableView.dequeueReusableCellWithIdentifier("MeTopCell", forIndexPath: indexPath) as! NBWMeTopTableViewCell
            configureTopCell(cell)
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("MeCell", forIndexPath: indexPath)
            configureMeCell(cell,indexPath)
            return cell
        }
    }
    
    func configureTopCell(cell:NBWMeTopTableViewCell){
        cell.avater.sd_setImageWithURL(NSURL(string: (userInfo?.avatar_large)!))
        cell.avater.layer.cornerRadius = 30
        cell.screenNameLabel.text      = userInfo?.screen_name
        cell.bioLabel.text             = userInfo?.user_description
        cell.weiboNumLabel.text        = "\((userInfo?.statuses_count)!)"
        cell.followNumLabel.text       = "\((userInfo?.friends_count)!)"
        cell.followerNumLabel.text     = "\((userInfo?.followers_count)!)"
    }
    
    func configureMeCell(cell:UITableViewCell,_ indexPath:NSIndexPath){
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        if indexPath.section == 1 {
            cell.textLabel?.text  = "New Friends"
            cell.imageView?.image = UIImage(named: "newFriends")
        }else if indexPath.section == 2 {
            if indexPath.row == 0 {
            cell.textLabel?.text  = "Albums"
            cell.imageView?.image = UIImage(named: "albums32")
            }else if indexPath.row == 1 {
            cell.textLabel?.text  = "My Reviews"
            cell.imageView?.image = UIImage(named: "review32")
            }else {
            cell.textLabel?.text  = "Likes"
            cell.imageView?.image = UIImage(named: "like32-1")
            }
        }else if indexPath.section == 3 {
            if indexPath.row == 0 {
            cell.textLabel?.text  = "Weibo Pay"
            cell.imageView?.image = UIImage(named: "weiboPay32")
            }else {
            cell.textLabel?.text  = "Weibo Fit"
            cell.imageView?.image = UIImage(named: "weiboFit32")
            }
        }else if indexPath.section == 4 {
            if indexPath.row == 0 {
            cell.textLabel?.text  = "Fanstop"
            cell.imageView?.image = UIImage(named: "fanstop32")
            }else{
            cell.textLabel?.text  = "Fans Service"
            cell.imageView?.image = UIImage(named: "fans32")
            }
        }else if indexPath.section == 5 {
            cell.textLabel?.text  = "Draft Box"
            cell.imageView?.image = UIImage(named: "draft32")
        }else {
            cell.textLabel?.text  = "More"
            cell.imageView?.image = UIImage(named: "more32")
        }
    }

}
