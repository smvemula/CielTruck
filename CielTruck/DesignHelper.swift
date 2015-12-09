//
//  DesignHelper.swift
//  PlayNFLBetting
//
//  Created by Vemula, Manoj (Contractor) on 9/18/15.
//  Copyright © 2015 Vemula, Manoj (Contractor). All rights reserved.
//

import UIKit
import Foundation

class DesignHelper {
    
    class func getTitleAttributedStringforTitle(title: String) -> NSAttributedString {
        return DesignHelper.getTitleAttributedStringforTitle(title, size: 18)
    }
    
    class func getTitleAttributedStringforTitle(title: String, size: CGFloat) -> NSAttributedString {
        return NSAttributedString(string: title.uppercaseString, attributes: [NSFontAttributeName:DesignHelper.getBoldFont(size), NSForegroundColorAttributeName: UIColor.whiteColor(), NSKernAttributeName: 2])
    }
    
    class func getTitleAttributedStringforTitle(title: String, font: UIFont, tracking: Int) -> NSAttributedString {
        return DesignHelper.getTitleAttributedStringforTitle(title, color: UIColor.whiteColor(), font: font, tracking: tracking)
    }
    
    class func getTitleAttributedStringforTitle(title: String, color: UIColor, font: UIFont, tracking: Int) -> NSAttributedString {
        return NSAttributedString(string: title.uppercaseString, attributes: [NSFontAttributeName:font, NSForegroundColorAttributeName: color, NSKernAttributeName: tracking/100])
    }
    
    class func getRegularFont(size: CGFloat) -> UIFont {
        return DesignHelper.defaultRegular(size)
    }
    class func getBoldFont(size: CGFloat) -> UIFont {
        return DesignHelper.defaultBold(size)
    }
    class func getItalicFont(size: CGFloat) -> UIFont {
        return DesignHelper.defaultItalic(size)
    }
    class func defaultRegular(size:CGFloat)->(UIFont){
        return UIFont(name: "HelveticaNeue", size: size)!
    }
    class func defaultBold(size:CGFloat)->(UIFont){
        return UIFont(name: "HelveticaNeue-Bold", size: size)!
    }
    class func defaultCondensedBold(size:CGFloat)->(UIFont){
        return UIFont(name: "HelveticaNeue-CondensedBold", size: size)!
    }
    class func defaultCondensedBlack(size:CGFloat)->(UIFont){
        return UIFont(name: "HelveticaNeue-CondensedBlack", size: size)!
    }
    class func defaultItalic(size:CGFloat)->(UIFont){
        return UIFont(name: "HelveticaNeue-Italic", size: size)!
    }
    class func defaultMedium(size:CGFloat)->(UIFont){
        return UIFont(name: "HelveticaNeue-Medium", size: size)!
    }
    class func defaultLight(size:CGFloat)->(UIFont){
        return UIFont(name: "HelveticaNeue-Light", size: size)!
    }
}