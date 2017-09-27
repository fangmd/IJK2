//
//  CustomUISlide.swift
//  MyOUC
//
//  Created by NercHackintosh on 2017/9/18.
//  Copyright © 2017年 北京泛在时代教育技术有限责任公司. All rights reserved.
//

import Foundation
import UIKit


class CustomUISlide: UISlider {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var bounds: CGRect = self.bounds
        bounds = bounds.insetBy(dx: -10, dy: -15)
        return bounds.contains(point)
    }
    
}
