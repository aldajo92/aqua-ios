//
//  Helpers+Extensions.swift
//  Aqua
//
//  Created by Edgard Aguirre Rozo on 10/22/16.
//  Copyright © 2016 Edgard Aguirre Rozo. All rights reserved.
//

import Foundation
import UIKit

struct HelpersExtensionsConfig {
    static let fontName = "Rubik-Regular"
}

func attriburedString(copyString: String,
                      font : UIFont = UIFont.defaultFontRegular(size: 32.0),
                      tracking : CGFloat = 0.0,
                      leading : CGFloat = 0.0,
                      textAlignment : NSTextAlignment = NSTextAlignment.left,
                      lineBreakMode : NSLineBreakMode = NSLineBreakMode.byWordWrapping,
                      color : UIColor = UIColor(red: 228.0/255.0, green: 227.0/255.0, blue: 255.0/255.0, alpha: 1.0),
                      underlined : Bool = false) -> NSAttributedString
{
    let attributes = customAttributes(font: font,
                                      tracking : tracking,
                                      leading : leading,
                                      textAlignment : textAlignment,
                                      lineBreakMode : lineBreakMode,
                                      color : color,
                                      underlined : underlined)
    
    let attributedString =  NSMutableAttributedString(string: copyString)
    attributedString.setAttributes(attributes, range: NSMakeRange(0, attributedString.length))
    
    return attributedString
}

func customAttributes(font : UIFont,
                      tracking : CGFloat = 0.0,
                      leading : CGFloat = 0.0,
                      textAlignment : NSTextAlignment = NSTextAlignment.left,
                      lineBreakMode : NSLineBreakMode = NSLineBreakMode.byTruncatingTail,
                      color : UIColor = UIColor.white,
                      underlined : Bool = false) -> Dictionary<String , AnyObject>
{
    var attributes = Dictionary<String , AnyObject>()
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.minimumLineHeight = leading / 2.0
    paragraphStyle.maximumLineHeight = leading / 2.0
    paragraphStyle.alignment = textAlignment
    paragraphStyle.lineBreakMode = lineBreakMode
    
    if underlined {
        attributes[NSUnderlineStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue as AnyObject?
    }
    
    attributes[NSParagraphStyleAttributeName] = paragraphStyle
    attributes[NSForegroundColorAttributeName] = color
    attributes[NSFontAttributeName] = font
    
    return attributes
}

func log(_ message: String) {
    print(message)
}

func delay(delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when) {
        closure()
    }
}

extension UIFont {
    
    class func defaultFontRegular(size : CGFloat) -> UIFont {
        return UIFont(name: HelpersExtensionsConfig.fontName, size: size)!
    }
}

extension UIImageView {
    
    func setAnimationImagesWithImageNameFormat(format: String) {
        var imageNameIndex = 1
        var sequenceImages = [UIImage]()
        var image = UIImage(named: String(format: format, imageNameIndex))
        
        while (image != nil) {
            sequenceImages.append(image!)
            imageNameIndex += 1
            let fileName = String(format: format, imageNameIndex)
            image = UIImage(named:fileName)
        }
        
        animationImages = sequenceImages
    }
}


