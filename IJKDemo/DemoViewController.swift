//
//  DemoViewController.swift
//  IJKDemo
//
//  Created by nercdev on 2017/6/13.
//  Copyright © 2017年 北京泛在时代教育技术有限责任公司. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class DemoViewControler: UIViewController{
    
    
    var videoManager: MyVideoManager = MyVideoManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoManager.mVC = self
        
        self.view.addSubview(videoManager.mView)
        
        videoManager.setSmallConstraints(parentView: self.view)
        videoManager.mDelegate = self
        
        
        let url = URL(string: "rtmp://live.hkstv.hk.lxdns.com/live/hks")
        
        videoManager.setUpPlayer(contentURL: url!)
        
        
        // 禁止滑动返回
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        videoManager.initMovieStateNotificationObservers()
        videoManager.prepareToPlay()
        videoManager.initScreenNotificationObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoManager.shutdown()
        videoManager.stopNet()
        
        videoManager.removeMovieNotificationObservers()
        videoManager.removeScreenNotificationObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 恢复滑动返回
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        
    }
    
    // full screen
    override var prefersStatusBarHidden: Bool{
        return videoManager.mPortrait
    }
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscapeRight, .landscapeLeft]
    }
    
}

extension DemoViewControler:DVideoManagerDelegate{
    
    /// 停止，正在加载
    func loading() {
        NSLog("DVideoManagerDelegate pause loading")
    }

    
    func backClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func play(playTime: TimeInterval) {
        NSLog("DVideoManagerDelegate play")
    }
    
    func stop(playTime: TimeInterval) {
        NSLog("DVideoManagerDelegate stop")
    }
    
    func pause() {
        NSLog("DVideoManagerDelegate pause")
    }
}
