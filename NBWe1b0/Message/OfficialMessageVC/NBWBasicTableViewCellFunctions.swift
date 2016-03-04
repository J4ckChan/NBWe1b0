//
//  NBWBasicTableViewCellFunctions.swift
//  NBWe1b0
//
//  Created by ChanLiang on 3/4/16.
//  Copyright © 2016 JackChan. All rights reserved.
//

import Foundation


func calculateTextLabelHeight(text:String,fontSize:CGFloat,viewWidth:CGFloat)->CGFloat{
    
    let labelText                          = text
    let labelTextNSString                  = NSString(CString:labelText, encoding: NSUTF8StringEncoding)
    let labelFont                          = UIFont.systemFontOfSize(fontSize, weight: UIFontWeightThin)
    let attributesDictionary               = [NSFontAttributeName:labelFont]
    let labelSize                          = CGSize(width: viewWidth-16, height:CGFloat.max)
    let options:NSStringDrawingOptions     = [.UsesLineFragmentOrigin,.UsesFontLeading]
    let labelRect                          = labelTextNSString!.boundingRectWithSize(labelSize, options: options, attributes: attributesDictionary,context: nil)
    
    return labelRect.height
}