//
//  NBWShareWithTableVC.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/8/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWShareWithTableVC: UITableViewController {
    
    let shareWithArray = ["Public","Only Me","Friends Circle"]
    var delegate:SendIndexDelegate?
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "shareWithCell")
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shareWithArray.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 30
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("shareWithCell", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = shareWithArray[indexPath.row]
        cell.textLabel?.font = UIFont.systemFontOfSize(13)
        cell.backgroundColor = UIColor.clearColor()
        

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.textLabel?.textColor = UIColor.orangeColor()
        dismissViewControllerAnimated(true) { () -> Void in
            self.delegate?.sendIndex(indexPath.row)
        }
    }
}
