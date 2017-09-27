//
//  MediaControllerViewController.swift
//  IJKDemo
//
//  Created by nercdev on 2017/6/12.
//  Copyright © 2017年 北京泛在时代教育技术有限责任公司. All rights reserved.
//

import Foundation
import SnapKit
import UIKit
import IJKMediaFramework

class MediaControllerViewController: UIViewController{
    
    
    var mPlayer: IJKMediaPlayback = IJKFFMoviePlayerController() // 实现了 IJKMediaPlayback delegate
    
    enum PlayerViewState{
        case small
        case fullScreenLeft
        case fullScreenRight
        case animating
        case portrait /// mScreenState 给屏幕使用
    }
    
    var mPlayerViewState: PlayerViewState = PlayerViewState.small
    
    // root view (controller ui , mPlayer.view)
    let mPlayerView = UIView()
    
    // ui
    let mViewController = UIView()
    let mBtnPlay: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "jc_play_normal"), for: .normal)
        return btn
    }()
    let mBtnPause: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "jc_pause_normal"), for: .normal)
        return btn
    }()
    let mLabelTotalDuration: UILabel = {
        let label = UILabel()
        label.text = "--:--"
        label.textColor = UIColor.white
        label.font = UIFont(name: label.font.fontName, size: CGFloat(12))
        return label
    }()
    let mLabelCurrentDuration: UILabel = {
        let label = UILabel()
        label.text = "--:--"
        label.textColor = UIColor.white
        label.font = UIFont(name: label.font.fontName, size: CGFloat(12))
        return label
    }()
    let mSlider = UISlider()
    let mBtnFullScrean: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "jc_enlarge"), for: .normal)
        
        return btn
    }()
    
    var mBeginDragMediaSlider = false
    //------
    
    
    // life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let options = IJKFFOptions.byDefault()
        
        
        //        let url = URL(string: "rtmp://live.hkstv.hk.lxdns.com/live/hks")
        let url = URL(string: "http://file1.symooc.nerc-edu.cn/Files/2017/4-28/a8592d42-fc1d-4171-a3b7-2b4ec6f58659.mp4")
        
        mPlayer = IJKFFMoviePlayerController(contentURL: url, with: options) //初始化播放器，播放在线视频或直播(RTMP)
        
        mPlayer.view.autoresizingMask = UIViewAutoresizing.init(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
        mPlayer.view.frame = self.view.bounds
        mPlayer.scalingMode = .aspectFit // 缩放模式
        mPlayer.shouldAutoplay = true //开启自动播放
        
        
        
        self.view.addSubview(mPlayerView)
        mPlayerView.addSubview((mPlayer.view)!)
        
        
        // media controller
        let playerViewGesture = UITapGestureRecognizer(target: self, action: #selector(playerViewTag))
        mPlayer.view.addGestureRecognizer(playerViewGesture)
        
        mBtnPlay.addTarget(self, action: #selector(play), for: .touchUpInside)
        mBtnPause.addTarget(self, action: #selector(pause), for: .touchUpInside)
        mBtnFullScrean.addTarget(self, action: #selector(fullScreen), for: .touchUpInside)
        
        let controllerViewGesture = UITapGestureRecognizer(target: self, action: #selector(viewControllerTap))
        mViewController.addGestureRecognizer(controllerViewGesture)
        
        mSlider.addTarget(self, action: #selector(didSliderTouchDown), for: .touchDown)
        mSlider.addTarget(self, action: #selector(didSliderTouchCancel), for: .touchCancel)
        mSlider.addTarget(self, action: #selector(didSliderTouchUp), for: [.touchUpInside, .touchUpOutside])
        mSlider.addTarget(self, action: #selector(didSliderValueChanged), for: .valueChanged)
        
        
        
        mPlayerView.addSubview(mViewController)
        mViewController.addSubview(mBtnPlay)
        mViewController.addSubview(mBtnPause)
        mViewController.addSubview(mLabelTotalDuration)
        mViewController.addSubview(mLabelCurrentDuration)
        mViewController.addSubview(mSlider)
        mViewController.addSubview(mBtnFullScrean)
        
        
        
        // init view
        
        
        
        // ------
        
        // add conts
        mPlayerView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view)
            make.top.equalTo(self.view).offset(64)
            make.height.equalTo(200)
        }
        
        mPlayer.view.snp.makeConstraints { (make) in
            make.size.equalTo(mPlayerView)
            make.edges.equalTo(mPlayerView)
        }
        
        // mediacontroller
        mViewController.snp.makeConstraints { (make) in
            make.edges.equalTo(mPlayer.view)
        }
        mBtnPlay.snp.makeConstraints { (make) in
            make.center.equalTo(mViewController)
            make.height.width.equalTo(36)
        }
        mBtnPause.snp.makeConstraints { (make) in
            make.center.equalTo(mViewController)
            make.height.width.equalTo(36)
        }
        mLabelCurrentDuration.snp.makeConstraints { (make) in
            make.bottom.equalTo(mViewController).offset(-10)
            make.left.equalTo(mViewController).offset(10)
        }
        mBtnFullScrean.snp.makeConstraints { (make) in
            make.right.equalTo(mViewController).offset(-10)
            make.width.height.equalTo(30)
            make.centerY.equalTo(mLabelCurrentDuration)
        }
        mLabelTotalDuration.snp.makeConstraints { (make) in
            make.bottom.equalTo(mViewController).offset(-10)
            make.right.equalTo(mBtnFullScrean.snp.left).offset(-10)
        }
        mSlider.snp.makeConstraints { (make) in
            make.bottom.equalTo(mViewController).offset(-14)
            make.height.equalTo(4)
            make.left.equalTo(mLabelCurrentDuration.snp.right).offset(10)
            make.right.equalTo(mLabelTotalDuration.snp.left).offset(-10)
        }
        //
        
        
        // 禁止滑动返回
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initMovieStateNotificationObservers()
        
        mPlayer.prepareToPlay()
        
        /// 开始 屏幕旋转监听
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mPlayer.shutdown()
        
        removeMovieNotificationObservers()
        /// 取消 屏幕旋转监听
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 恢复滑动返回
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // controller
    /// 进度条 按下
    func didSliderTouchDown(){
        print("down")
        mBeginDragMediaSlider = true
    }
    /// 进度条 取消
    func didSliderTouchCancel(){
        mBeginDragMediaSlider = false
        
    }
    /// 进度条 松开
    func didSliderTouchUp(){
        mBeginDragMediaSlider = false
        
        showAndFade()
    }
    /// 进度条 值改变（被拖动）
    func didSliderValueChanged(){
        // 修改播放进度
        mPlayer.currentPlaybackTime = TimeInterval(mSlider.value)
        
        showAndFade()
        
        refreshMediaControl()
    }
    
    func viewControllerTap(_ sender:UITapGestureRecognizer){
        print("viewControllerTap")
        hideMediaControllerView()
    }
    
    func playerViewTag(_ sender:UITapGestureRecognizer){
        print("playerViewTag")
        showAndFade()
        refreshMediaControl() // 触发进度条更新
    }
    
    var mMediaControllerTimer : Timer?
    
    func showNoFade(){
        showMediaControllerView()
        cancelDelayedHide()
        refreshMediaControl()
    }
    
    func showAndFade(){
        showNoFade()
        mMediaControllerTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(hideMediaControllerView), userInfo: nil, repeats: false)
    }
    
    func hideMediaControllerView(){
        mViewController.isHidden = true
        cancelDelayedHide()
    }
    
    func showMediaControllerView(){
        mViewController.isHidden = false
    }
    
    func cancelDelayedHide(){
        if mMediaControllerTimer != nil{
            mMediaControllerTimer?.invalidate()
            mMediaControllerTimer = nil
        }
    }
    
    var mIsFull = false    
    
    func fullScreen(){
        if !mIsFull{
            enterFullScreen(.fullScreenRight)
            print("fullScrean")
            
        } else {
            exitFullscreen()
            print("exitFullscreen")
        }
        
        mIsFull = !mIsFull
    }
    
    func play(){
        if !mPlayer.isPlaying(){
            mPlayer.play()
        }
    }
    
    func pause(){
        if mPlayer.isPlaying(){
            mPlayer.pause()
        }
    }
    
    func refreshMediaControl(){
        // status
        let isPlaying = mPlayer.isPlaying()
        mBtnPlay.isHidden = isPlaying;
        mBtnPause.isHidden = !isPlaying;
        
        // duration
        let duration = mPlayer.duration
        let intDuration = Int(duration + 0.5)
        if intDuration > 0{
            mSlider.maximumValue = Float(duration);
            mLabelTotalDuration.text = String(format: "%02d:%02d", intDuration / 60, intDuration % 60)
            
        }else{
            mSlider.maximumValue = 1.0
            mLabelTotalDuration.text = "--:--"
        }
        
        // position
        var position: TimeInterval
        if mBeginDragMediaSlider{
            position = TimeInterval(mSlider.value)
        } else {
            position = mPlayer.currentPlaybackTime
        }
        let intPosition = Int(position + 0.5)
        if intPosition > 0{
            mSlider.value = Float(position)
        } else {
            mSlider.value = 0
        }
        mLabelCurrentDuration.text = String(format: "%02d:%02d", intPosition / 60, intPosition % 60)
        
        //        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshMediaControl) object:nil];
        
        if !mViewController.isHidden{
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(refreshMediaControl), userInfo: nil, repeats: false)
        }
        
    }
    
    //
    func loadStateDidChange(notification: Notification){
        let loadState = mPlayer.loadState
        switch loadState{
        case IJKMPMovieLoadState.playthroughOK:
            /// 缓冲结束自动播放
            
            break
        case IJKMPMovieLoadState.stalled:
            /// 网络差 自动停止
            
            break
        case IJKMPMovieLoadState.playable:
            /// 缓冲结束可以播放
            
            break
        default: break
        }
        
    }
    
    /// 视频结束的原因
    func moviePlayBackDidFinish(notification: Notification){
        let userInfo = notification.userInfo as! [String: Any]
        let reason = userInfo[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as! Int
        switch reason {
        case IJKMPMovieFinishReason.playbackEnded.rawValue:
            NSLog("IJKMPMovieFinishReasonPlaybackEnded ")
            break
        case IJKMPMovieFinishReason.userExited.rawValue:
            NSLog("IJKMPMovieFinishReasonUserExited ")
            break
        case IJKMPMovieFinishReason.playbackError.rawValue:
            NSLog("IJKMPMovieFinishReasonPlaybackError")
            break
        default:
            NSLog("default ")
            break
        }
    }
    
    func mediaIsPreparedToPlayDidChange(notification: Notification){
        
    }
    
    /// 播放状态改变
    func moviePlayBackStateDidChange(notification: Notification){
        let state = mPlayer.playbackState
        switch (state){
        case IJKMPMoviePlaybackState.stopped:
            NSLog("IJKMPMoviePlaybackStateStopped ")
            break
        case IJKMPMoviePlaybackState.playing:
            NSLog("IJKMPMoviePlaybackStatePlaying  ")
            break
        case IJKMPMoviePlaybackState.paused:
            NSLog("IJKMPMoviePlaybackStatePaused  ")
            break
        case IJKMPMoviePlaybackState.interrupted:
            NSLog("IJKMPMoviePlaybackStateInterrupted  ")
            break
        case IJKMPMoviePlaybackState.seekingForward:
            NSLog("IJKMPMoviePlaybackStateSeekingForward ")
            break
        case IJKMPMoviePlaybackState.seekingBackward:
            NSLog("IJKMPMoviePlaybackStateSeekingBackward ")
            break
        default:break
        }
        
        refreshMediaControl()
    }
    
    /// 初始化监听
    func initMovieStateNotificationObservers(){
        //监听网络环境，监听缓冲方法
        NotificationCenter.default.addObserver(self, selector: #selector(loadStateDidChange), name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: mPlayer)
        //监听直播完成回调
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackDidFinish), name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: mPlayer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(mediaIsPreparedToPlayDidChange), name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: mPlayer)
        //监听用户主动操作
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackStateDidChange), name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: mPlayer)
    }
    
    /// 取消 监听
    func removeMovieNotificationObservers(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: mPlayer)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: mPlayer)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: mPlayer)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: mPlayer)
        
    }
    
    
    // full screen
    var mPortrait = false
    override var prefersStatusBarHidden: Bool{
        return mPortrait
    }
    override var shouldAutorotate: Bool {
        return true
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscapeRight, .landscapeLeft]
    }
    
    
    /// 屏幕旋转 监听
    var mScreenState: PlayerViewState = .portrait
    func rotated() {
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft{
            mScreenState = .fullScreenLeft
            mPortrait = false
            enterFullScreen(.fullScreenLeft)
        }else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight{
            mPortrait = false
            mScreenState = .fullScreenRight
            enterFullScreen(.fullScreenRight)
        }else if UIDevice.current.orientation == UIDeviceOrientation.portrait{
            mScreenState = .portrait
            mPortrait = true
            exitFullscreen()
        }
    }
    
    
    
    // 方案一 https://techblog.toutiao.com/2017/03/28/fullscreen/
    var parentView: UIView?
    var mPlayerViewFrame: CGRect?
    
    func enterFullScreen(_ orientationState: PlayerViewState){
        
        mPlayerViewState = .animating
        
        //TODO: 如果要封装就需要记录 makeConstraints 。纪录进入全屏前的 parentView 和 frame
        parentView = self.mPlayerView.superview!
        mPlayerViewFrame = self.mPlayerView.frame
        
        // movieView 移到 window 上
        //        let rectInWindow = mPlayerView.convert(mPlayerView.bounds, to: UIApplication.shared.keyWindow)
        mPlayerView.removeFromSuperview()
        //        mPlayerView.frame = rectInWindow
        UIApplication.shared.keyWindow?.addSubview(mPlayerView)
        
        self.mPlayerView.updateConstraints()
        UIView.animate(withDuration: 0.5, animations: {
            /// 先设置 playerView 旋转角度为 0
            self.mPlayerView.transform = CGAffineTransform.init(rotationAngle: CGFloat(0))
            if orientationState == .fullScreenRight {
                if self.mScreenState != .fullScreenRight{
                    self.mPlayerView.transform = CGAffineTransform.init(rotationAngle: CGFloat(-Double.pi/2))
                }
            }else if orientationState == .fullScreenLeft{
                if self.mScreenState != .fullScreenLeft{
                    self.mPlayerView.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi/2))
                }
            }
            
            if self.mScreenState == .fullScreenLeft || self.mScreenState == .fullScreenRight{
                self.mPlayerView.snp.makeConstraints({ (make) in
                    make.center.equalTo(self.mPlayerView.superview!)
                    make.width.equalTo(self.mPlayerView.superview!.snp.width)
                    make.height.equalTo(self.mPlayerView.superview!.snp.height)
                })
                
            }else{
                self.mPlayerView.snp.makeConstraints({ (make) in
                    make.center.equalTo(self.mPlayerView.superview!)
                    make.width.equalTo(self.mPlayerView.superview!.snp.height)
                    make.height.equalTo(self.mPlayerView.superview!.snp.width)
                })
            }
            
            self.mPlayerView.layoutIfNeeded()
            
        }) { (finished) in
            self.mPlayerViewState = orientationState
        }
    }
    
    func exitFullscreen(){
        
        if (self.mPlayerViewState != .fullScreenLeft && self.mPlayerViewState != .fullScreenRight) {
            return;
        }
        
        self.mPlayerViewState = .animating
        
        self.mPlayerView.updateConstraints()
        UIView.animate(withDuration: 0.5, animations: {
            self.mPlayerView.transform = CGAffineTransform.init(rotationAngle: CGFloat(0))
            
            self.mPlayerView.snp.makeConstraints { (make) in
                make.width.equalTo(self.mPlayerView.superview!)
                make.top.equalTo(self.mPlayerView.superview!).offset(64)
                make.height.equalTo(200)
            }
            
            self.mPlayerView.layoutIfNeeded()
        }) { (finished) in
            self.mPlayerView.removeFromSuperview()
            self.view.addSubview(self.mPlayerView)
            
            self.mPlayerView.snp.makeConstraints { (make) in
                make.width.equalTo(self.view)
                make.top.equalTo(self.view).offset(64)
                make.height.equalTo(200)
                make.centerX.equalTo(self.view)
            }
            self.mPlayerView.layoutIfNeeded()
            self.mPlayerViewState = .small
        }
    }
    
    
}
