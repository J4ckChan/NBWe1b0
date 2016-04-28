//
//  AppDelegate.swift
//  NBWe1b0
//
//  Created by ChanLiang on 1/6/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

let appKey = "727947860"
let appSecret = "357abfd7118c26498b91d9dc3b409546"
let redirectURL = "https://api.weibo.com/oauth2/default.html"

var accessToken:String = "2.00HKoGiB0WU5Qn25f63843bdEJB58C"
var userID:String = "1567914411"
var refreshToken:String?
var userScreenName:String = "J4ck_Chan"
var managerContext:NSManagedObjectContext?
var userInfo:WeiboUser?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?
    let userShow                  = "https://api.weibo.com/2/users/show.json"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //weiboSDK
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp(appKey)
        fetchUserDefault()
    
        //CoreData
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managerContext = appDelegate.managedObjectContext
    
        userInfo = fetchUserData(userID)
        if userInfo == nil {
            usersShow()
        }
        
        //NetworkMonitor
        let listenerBool = NetworkReachabilityManager()?.startListening()
        if listenerBool! {
            print("Start Network monitor")
        }
    
        return true
    }
    
    func fetchUserDefault(){
        let userDefault = NSUserDefaults.standardUserDefaults()
        if userDefault.objectForKey("accessToken") != nil &&  userDefault.objectForKey("userId") != nil && userDefault.objectForKey("refreshToken") != nil {
            accessToken     = userDefault.objectForKey("accessToken") as! String
            userID          = userDefault.objectForKey("userId") as! String
            refreshToken    = userDefault.objectForKey("refreshToken") as? String
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return WeiboSDK.handleOpenURL(url, delegate: self)
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WeiboSDK.handleOpenURL(url, delegate: self)
    }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
  }

  // MARK: - Core Data stack

  lazy var applicationDocumentsDirectory: NSURL = {
      // The directory the application uses to store the Core Data store file. This code uses a directory named "ChanStudio.NBWe1b0" in the application's documents Application Support directory.
      let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
      return urls[urls.count-1]
  }()

  lazy var managedObjectModel: NSManagedObjectModel = {
      // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
      let modelURL = NSBundle.mainBundle().URLForResource("NBWe1b0", withExtension: "momd")!
      return NSManagedObjectModel(contentsOfURL: modelURL)!
  }()

  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
      // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
      // Create the coordinator and store
      let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
      let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
      var failureReason = "There was an error creating or loading the application's saved data."
      do {
          try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
      } catch {
          // Report any error we got.
          var dict = [String: AnyObject]()
          dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
          dict[NSLocalizedFailureReasonErrorKey] = failureReason

          dict[NSUnderlyingErrorKey] = error as NSError
          let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
          // Replace this with code to handle the error appropriately.
          // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
          NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
          abort()
      }
      
      return coordinator
  }()

  lazy var managedObjectContext: NSManagedObjectContext = {
      // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
      let coordinator = self.persistentStoreCoordinator
      var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
      managedObjectContext.persistentStoreCoordinator = coordinator
      return managedObjectContext
  }()

  // MARK: - Core Data Saving support

  func saveContext () {
      if managedObjectContext.hasChanges {
          do {
              try managedObjectContext.save()
          } catch {
              // Replace this implementation with code to handle the error appropriately.
              // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
              let nserror = error as NSError
              NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
              abort()
          }
      }
  }

}

extension AppDelegate: WeiboSDKDelegate{
    
    func didReceiveWeiboRequest(request: WBBaseRequest!) {
        
    }
    
    func didReceiveWeiboResponse(response: WBBaseResponse!) {
        if response.isKindOfClass(WBAuthorizeResponse){
            accessToken  = (response as! WBAuthorizeResponse).accessToken
            userID       = (response as! WBAuthorizeResponse).userID
            refreshToken = (response as! WBAuthorizeResponse).refreshToken
            
            print("accessToken = \(accessToken), userID = \(userID)")
            
            //UserDefaut
            userDefault()
            
            //Fetch userInfo
            usersShow()
        }
    }
    
    func userDefault(){
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(accessToken, forKey: "accessToken")
        userDefault.setObject(userID, forKey: "userId")
        userDefault.setObject(refreshToken, forKey: "refreshToken")
    }
    
    func usersShow(){
        
        Alamofire.request(.GET, userShow, parameters: ["access_token":accessToken,"uid":Int(userID)!], encoding: ParameterEncoding.URL, headers: nil)
            .responseJSON { (Response) -> Void in
                
                do{
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(Response.data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                    
                    userScreenName = (jsonDictionary["screen_name"] as? String)!
                    
                    userInfo = weiboUserManagedObject()
                    importUserDataFromJSON(userInfo!, userDict: jsonDictionary)
                    
                    managerContextSave()
                    
                }catch let error as NSError {
                    print("Error:\(error.localizedDescription)")
                }
         }
    }
}

