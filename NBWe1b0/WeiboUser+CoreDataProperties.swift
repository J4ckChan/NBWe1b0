//
//  WeiboUser+CoreDataProperties.swift
//  NBWe1b0
//
//  Created by ChanLiang on 1/17/16.
//  Copyright © 2016 JackChan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension WeiboUser {

    @NSManaged var allow_all_act_msg: NSNumber?
    @NSManaged var allow_all_comment: NSNumber?
    @NSManaged var avatar_hd: String?
    @NSManaged var avatar_large: String?
    @NSManaged var bi_followers_count: NSNumber?
    @NSManaged var city: NSNumber?
    @NSManaged var created_at: String?
    @NSManaged var domain: String?
    @NSManaged var favourites_count: NSNumber?
    @NSManaged var follow_me: NSNumber?
    @NSManaged var followers_count: NSNumber?
    @NSManaged var following: NSNumber?
    @NSManaged var friends_count: NSNumber?
    @NSManaged var gender: String?
    @NSManaged var geo_enabled: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var idstr: String?
    @NSManaged var lang: String?
    @NSManaged var location: String?
    @NSManaged var name: String?
    @NSManaged var online_status: NSNumber?
    @NSManaged var profile_image_url: String?
    @NSManaged var profile_url: String?
    @NSManaged var province: NSNumber?
    @NSManaged var remark: String?
    @NSManaged var screen_name: String?
    @NSManaged var statuses_count: NSNumber?
    @NSManaged var url: String?
    @NSManaged var user_description: String?
    @NSManaged var verified: NSNumber?
    @NSManaged var verified_reason: String?
    @NSManaged var verified_type: NSNumber?
    @NSManaged var weihao: String?
    @NSManaged var status: NSSet?

}
