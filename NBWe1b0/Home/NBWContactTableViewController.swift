//
//  NBWContactTableViewController.swift
//  NBWe1b0
//
//  Created by ChanLiang on 2/19/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit
import CoreData

protocol SendScreenNameToTextViewDelegate{
    func sendScreenName(screenName:String)
}

class NBWContactTableViewController: UITableViewController {
    
    struct InitialList{
        var initial:String?
        var array:[String]?
    }
    
    var tableViewArray = [InitialList]()
    var contactArray = [WeiboUser]()
    var contactResultController:NBWContactResultTableViewController?
    var searchController :UISearchController?
    var searchControllerWasActive:Bool?
    var searchControllerSearchFieldWasFirstResponder:Bool?
    var screenNameArray = [String]()
    var searchResults = [String]()
    var selectedScreenName:String?
    var sendScreenNameDelegate:SendScreenNameToTextViewDelegate?
    
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .Done, target: self, action: #selector(NBWContactTableViewController.dismissSelf))
        self.navigationItem.title = "Contact"
        self.navigationController?.navigationBar.tintColor = UIColor.lightGrayColor()
        
        // SearchController
        setupSearchController()
        
        // Sort
        sortContactData(self.contactArray)
        
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "reuseIdentifier")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.searchControllerWasActive != nil) {
            self.searchControllerWasActive = false
            self.searchController?.active = self.searchControllerWasActive!
            
            if (self.searchControllerSearchFieldWasFirstResponder != nil) {
                self.searchController?.searchBar.becomeFirstResponder()
                self.searchControllerSearchFieldWasFirstResponder = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupSearchController(){
        self.contactResultController = NBWContactResultTableViewController.init()
        self.searchController = UISearchController.init(searchResultsController: contactResultController)
        searchController!.searchResultsUpdater = self
        searchController!.searchBar.sizeToFit()
        searchController!.searchBar.searchBarStyle = .Minimal
        self.tableView.tableHeaderView = searchController!.searchBar
        
        self.contactResultController?.tableView.delegate = self
        self.searchController?.delegate = self
        self.searchController?.dimsBackgroundDuringPresentation = false
        self.searchController?.searchBar.delegate = self
        self.definesPresentationContext = true

    }
    
    func sortContactData(contactArray:[WeiboUser]){
        
        for user in contactArray {
            
            let chinese = user.screen_name
            let chineseCFString = NSMutableString(string: chinese!) as CFMutableStringRef
            
            CFStringTransform(chineseCFString, nil, kCFStringTransformMandarinLatin, false)
            CFStringTransform(chineseCFString, nil, kCFStringTransformStripCombiningMarks, false)
            
            let chineseString = chineseCFString as String
            
            let index = chineseString.startIndex.advancedBy(1)
            let initialUppercase = chineseString.substringToIndex(index).uppercaseString
            
            if tableViewArray.count == 0 {
                
                var initial = InitialList()
                initial.initial = initialUppercase
                initial.array = [chinese!]
                tableViewArray.append(initial)
                
            }else{
                var flag = 0
                for index in 0 ..< tableViewArray.count {
                    
                    if tableViewArray[index].initial == initialUppercase {
                        flag = 1
                        tableViewArray[index].array?.append(chinese!)
                    }
                }
                if flag == 0 {
                    var initial = InitialList()
                    initial.initial = initialUppercase
                    initial.array = [chinese!]
                    tableViewArray.append(initial)
                }
                
            }
        }
        
        self.tableViewArray.sortInPlace { (list1, list2) -> Bool in
            if list1.initial < list2.initial {
                return true
            }else{
                return false
            }
        }
        
        for item in self.tableViewArray {
            if (item.array != nil) {
                for screenName in item.array! {
                    self.screenNameArray.append(screenName)
                }
            }
        }
    }
    
    func dismissSelf(){

        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.tableViewArray.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (self.tableViewArray[section].array)!.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableViewArray[section].initial
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...
        let screenName = self.tableViewArray[indexPath.section].array![indexPath.row]
        cell.textLabel?.text = screenName

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.tableView == tableView {
            self.selectedScreenName = self.tableViewArray[indexPath.section].array![indexPath.row]
        }
        
        if self.contactResultController?.tableView == tableView {
            self.selectedScreenName = self.searchResults[indexPath.row]
            dismissSelf()
        }
        
        self.sendScreenNameDelegate?.sendScreenName(self.selectedScreenName!)
        dismissSelf()
    }
}

extension NBWContactTableViewController:UISearchControllerDelegate,UISearchBarDelegate,UISearchResultsUpdating{
    
    //UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    //UISearchControllerDelegate
    
    
    //UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText =  searchController.searchBar.text
        self.searchResults = self.screenNameArray
        
        let strippedString = searchText?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        var searchItems:[String]?
        if strippedString?.characters.count > 0 {
            searchItems = strippedString?.componentsSeparatedByString(" ")
        }
        
        if searchItems != nil {
            for stringSearch in searchItems! {
                searchResults = searchResults.filter({ (String) -> Bool in
                    if ((String.rangeOfString(stringSearch)?.startIndex) != nil) {
                        return true
                    }else{
                        return false
                    }
                })
            }
        }
        
        let resultVC = self.contactResultController
        resultVC?.results = self.searchResults
        resultVC?.tableView.reloadData()
    }
}
