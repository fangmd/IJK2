//
//  UIColor+Custom.swift
//  MyOUC
//
//  Created by nercdev on 2017/5/22.
//  Copyright © 2017年 北京泛在时代教育技术有限责任公司. All rights reserved.
//

import Foundation
import UIKit

extension UIColor{
    static func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func fromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func color1() -> UIColor{
        return fromRGB(rgbValue: 0x333333)
    }
    
    
    static func colorPrimary() -> UIColor{
        return fromRGB(rgbValue: 0x4A4A63)
    }
    
    static func bgGrey() -> UIColor{
        return fromRGB(rgbValue: 0xf3f0f0)
    }
    
    static func bgGreyf5f5f5() -> UIColor{
        return fromRGB(rgbValue: 0xf5f5f5)
    }
    
    static func bgGreyTrans() -> UIColor{
        return fromRGB(rgbValue: 0x44444444).withAlphaComponent(0.4)
    }
    
    static func divideLineGrey() -> UIColor{
        return fromRGB(rgbValue: 0xe7e7e7)
    }
    
    static func divideLineGreyd8d8d8() -> UIColor{
        return fromRGB(rgbValue: 0xd8d8d8)
    }
    
    static func lineGrey() -> UIColor{
        return fromRGB(rgbValue: 0xe5e3e3)
    }
    
    /// 颜色更深
    static func lineGrey2() -> UIColor{
        return fromRGB(rgbValue: 0xb9b9b9)
    }
    
    static func lineGreyE2E0E1() -> UIColor{
        return fromRGB(rgbValue: 0xE2E0E1)
    }
    
    static func pinkBg() -> UIColor{
        return fromRGB(rgbValue: 0xf4f0f1)
    }
    
    static func bgRed() -> UIColor{
        return fromRGB(rgbValue: 0xFF4A4A)
    }
    
    static func myGreen() -> UIColor{
        return fromRGB(rgbValue: 0x4CAF50)
    }
    
    // text color
    static func textStander() -> UIColor{
        return fromRGB(rgbValue: 0x5d5d5d)
    }
    
    static func textSmall() -> UIColor{
        return fromRGB(rgbValue: 0x919191)
    }
    
    static func text808080() -> UIColor{
        return fromRGB(rgbValue: 0x808080)
    }

    static func textRed() -> UIColor{
        return fromRGB(rgbValue: 0xff4c48)
    }
    
    //
    
    
}
