//
//  NBWContactTableViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 2/19/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit
import CoreData

class NBWContactTableViewController: UITableViewController {
    
    var contactArray = [WeiboUser]()
    
    init(contactArray:[WeiboUser]){
        super.init(nibName: nil, bundle: nil)
        self.contactArray = contactArray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .Done, target: self, action: Selector("dismissSelf"))
        self.navigationItem.title = "Contact"
        self.navigationController?.navigationBar.tintColor = UIColor.lightGrayColor()
        
        // SearchController
        setupSearchController()
        
        // Sort
        sortContactData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupSearchController(){
        let contactResultController = NBWContactResultTableViewController.init()
        let searchController = UISearchController.init(searchResultsController: contactResultController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.searchBarStyle = .Minimal
        self.tableView.tableHeaderView = searchController.searchBar
    }
    
    func sortContactData(){
        
        let chinese = "陈良"
        let chineseCFString = NSMutableString(string: chinese) as CFMutableStringRef
        
        CFStringTransform(chineseCFString, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(chineseCFString, nil, kCFStringTransformStripCombiningMarks, false)
        print(chineseCFString)
        
    }
    
    func dismissSelf(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NBWContactTableViewController:UISearchControllerDelegate,UISearchBarDelegate,UISearchResultsUpdating{
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
}
