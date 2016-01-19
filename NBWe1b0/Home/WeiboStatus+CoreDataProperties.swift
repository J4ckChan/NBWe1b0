//
//  WeiboStatus+CoreDataProperties.swift
//  NBWe1b0
//
//  Created by ChanLiang on 1/18/16.
//  Copyright © 2016 JackChan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension WeiboStatus {

    @NSManaged var attitudes_count: NSNumber?
    @NSManaged var bmiddle_pic: String?
    @NSManaged var comments_count: NSNumber?
    @NSManaged var created_at: NSDate?
    @NSManaged var favorited: NSNumber?
    @NSManaged var id: String?
    @NSManaged var in_reply_to_screen_name: String?
    @NSManaged var in_reply_to_status_id: String?
    @NSManaged var in_reply_to_user_id: String?
    @NSManaged var original_pic: String?
    @NSManaged var reposts_count: NSNumber?
    @NSManaged var source: String?
    @NSManaged var text: String?
    @NSManaged var thumbnail_pic: String?
    @NSManaged var user: WeiboUser?

}
