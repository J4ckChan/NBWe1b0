//
//  WeiboStatusPics+CoreDataProperties.swift
//  NBWe1b0
//
//  Created by ChanLiang on 1/20/16.
//  Copyright © 2016 JackChan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension WeiboStatusPics {

    @NSManaged var pic: String?
    @NSManaged var status: WeiboStatus?

}
