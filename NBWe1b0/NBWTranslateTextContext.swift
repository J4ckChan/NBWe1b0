//
//  NBWTranslateTextContext.swift
//  NBWe1b0
//
//  Created by ChanLiang on 5/16/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import Foundation

func translateEmojiText(str:String) -> NSAttributedString {
    let path = NSBundle.mainBundle().pathForResource("emoji", ofType: "plist")
    let emojiArray = NSArray(contentsOfFile: path!)
    
    let attributeString = NSMutableAttributedString(string: str)
    let pattern = "\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"

    var regularExpression:NSRegularExpression?
    do{
        regularExpression = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
    }catch let error as NSError {
        print(error.localizedDescription)
    }
    
    let resultArray = regularExpression!.matchesInString(str, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, str.characters.count))
    
    for checkingResult in resultArray.reverse() {
        let nsRange = checkingResult.range
        let nsStr = NSString(string: str)
        let subString = nsStr.substringWithRange(nsRange)
        
        for emojiDict in emojiArray! {
            if  emojiDict["chs"] as! String == subString  {
                let attachment = NSTextAttachment()
                let image = UIImage(named: emojiDict["png"] as! String)
                attachment.image = imageToSmallSize(image!)
                let imageStr = NSAttributedString(attachment: attachment)
                
                attributeString.replaceCharactersInRange(nsRange, withAttributedString: imageStr)
            }
        }
    }

    return attributeString
}

func imageToSmallSize(image:UIImage) -> UIImage {
    let smallSize = CGSize(width: 20, height: 20)
    UIGraphicsBeginImageContext(smallSize)
    image.drawInRect(CGRectMake(0, 0, smallSize.width, smallSize.height))
    let smallImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return smallImage
}
