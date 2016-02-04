//
//  NBWComment.swift
//  NBWe1b0
//
//  Created by ChanLiang on 2/4/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import UIKit

class NBWComment: NSObject {
    
    var screenName:String?
    var createdAt:String?
    var avatarLargerURL:String?
    var text:String?
    
    init(screenName:String,createdAt:String,avatarLargerURL:String,text:String) {
        super.init()
        self.screenName      = screenName
        self.createdAt       = createdAt
        self.avatarLargerURL = avatarLargerURL
        self.text            = text
    }
}
