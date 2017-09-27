//
//  MyVideoManager.swift
//  IJKDemo
//
//  Created by nercdev on 2017/6/13.
//  Copyright © 2017年 北京泛在时代教育技术有限责任公司. All rights reserved.
//

import Foundation
import UIKit


class MyVideoManager: DVideoManager{
    
    override func setSmallConstraints(parentView: UIView) {        
        mView.snp.makeConstraints { (make) in
            make.width.equalTo(parentView)
            make.top.equalTo(parentView).offset(64)
            make.height.equalTo(200)
            make.centerX.equalTo(parentView)
        }
    }
    
    
}
