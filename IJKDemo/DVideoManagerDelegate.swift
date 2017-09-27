//
//  DVideoManagerDelegate.swift
//  IJKDemo
//
//  Created by nercdev on 2017/6/13.
//  Copyright © 2017年 北京泛在时代教育技术有限责任公司. All rights reserved.
//

import Foundation

protocol DVideoManagerDelegate{
    
    func backClick()
    
    func pause()
    
    /// 停止，正在加载
    func loading()
    
    func play(playTime: TimeInterval)
    
    func stop(playTime: TimeInterval)
    
    
    
}

