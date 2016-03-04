//
//  Comment+CoreDataProperties.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/4/16.
//  Copyright © 2016 JackChan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Comment {

    @NSManaged var created_at: NSDate?
    @NSManaged var id: NSNumber?
    @NSManaged var idstr: String?
    @NSManaged var mid: String?
    @NSManaged var source: String?
    @NSManaged var text: String?
    @NSManaged var reply_comment: Comment?
    @NSManaged var status: WeiboStatus?
    @NSManaged var user: WeiboUser?

}
