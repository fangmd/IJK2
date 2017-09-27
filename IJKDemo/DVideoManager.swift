//
//  DVideoView.swift
//  IJKDemo
//
//  Created by nercdev on 2017/6/13.
//  Copyright © 2017年 北京泛在时代教育技术有限责任公司. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import IJKMediaFramework
import ReachabilitySwift

class DVideoManager: NSObject{
    
    static let TAG = "DVideoManager"
    
    /// 播放器
    var mPlayer: IJKMediaPlayback = IJKFFMoviePlayerController() // 实现了 IJKMediaPlayback delegate
    
    var mDelegate: DVideoManagerDelegate?
    
    /// 状态
    enum PlayerViewState{
        case small
        case fullScreenLeft
        case fullScreenRight
        case animating
        case portrait /// mScreenState 给屏幕使用
    }
    
    var mPlayerViewState: PlayerViewState = PlayerViewState.small
    
    /// container root view (controller ui , mPlayer.view)
    let mView: UIView = {
        let view = UIView()
        view.backgroundColor = DVideoManager.fromRGB(rgbValue: 0x44444444)
        return view
    }()
    
    // ui
    let mViewController = UIView()
    let mTopBg: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        //        let gradient = CAGradientLayer()
        //        gradient.frame = view.bounds
        //        gradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        //        view.layer.insertSublayer(gradient, at: 0)
        
        return view
    }()
    let mBtnBack: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "jc_back_normal"), for: .normal)
        return btn
    }()
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
    let mIVLoading: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "jc_loading_bg"))
        imageView.isHidden = true
        return imageView
    }()
    
    let mBottomBg: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 32))
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
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
    let mCacheProgress: UIProgressView = {
        let progress = UIProgressView()
        progress.trackTintColor = UIColor.clear
        progress.progressTintColor = UIColor.fromRGB(rgbValue: 0xcccccc)
        progress.setProgress(0, animated: false)
        return progress
    }()
    let mSlider: CustomUISlide = {
        let slide = CustomUISlide()
        slide.setThumbImage(UIImage(named: "slide"), for: .normal)
        
        return slide
    }()
    let mBtnFullScrean: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "jc_enlarge"), for: .normal)
        
        return btn
    }()
    
    var mBeginDragMediaSlider = false
    //------
    
    // net
    var mIsNetLimited = true
    weak var mVC: UIViewController?
    var mReachability: Reachability?
    
    func setUpNet(){
        mReachability = Reachability()!
        mReachability?.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async() {
                if reachability.isReachableViaWiFi {
                    print("NET Reachable via WiFi")
                } else {
                    print("NET Reachable via Cellular")
                    self.showNetLimitedDialog()
                }
            }
        }
        mReachability?.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async() {
                print("NET Not reachable")
            }
        }
        
        do {
            try mReachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func stopNet(){
        mReachability?.stopNotifier()
    }
    
    func showNetLimitedDialog(){
        showPause()
        
        let dialog = UIAlertController(title: "提示", message: "当前使用的是移动网络，是否继续播放视频?", preferredStyle: UIAlertControllerStyle.alert)
        dialog.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.destructive, handler: { (action) in
            NSLog("NET OK")
            self.mBtnPlay.sendActions(for: .touchUpInside)
        }))
        
        dialog.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: { (action) in
            NSLog("NET Cancel")
        }))
        
        mVC?.present(dialog, animated: true) {
            NSLog("NET dialog show")
        }
    }
    //
    
    
    override init() {
        super.init()
        
        // 去除
        setLoggerLevel()
        setUpView()
    }
    
    func setUpView(){
        
        initView()
    }
    
    init(viewController: UIViewController) {
        mVC = viewController
        super.init()
    }
    // play 相关
    /// 停止播放？
    func shutdown(){
        mPlayer.shutdown()
        stopNet()
    }
    /// 视频准备完成后自动播放
    func prepareToPlay(){
        mPlayer.prepareToPlay()
    }
    //--------
    
    func setLoggerLevel(){
        IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_SILENT)
    }
    
    func setUpPlayer(contentURL: URL, options: IJKFFOptions = IJKFFOptions.byDefault(),shouldAutoplay: Bool = false, scalingMode: IJKMPMovieScalingMode = .aspectFit, netLimited: Bool = true){
        
        mPlayer = IJKFFMoviePlayerController(contentURL: contentURL, with: options) //初始化播放器，播放在线视频或直播(RTMP)
        
        // 去除
        setLoggerLevel()
        
        mPlayer.view.autoresizingMask = UIViewAutoresizing.init(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
        //        mPlayer.view.frame = self.view.bounds
        mPlayer.scalingMode = scalingMode // 缩放模式
        mPlayer.shouldAutoplay = shouldAutoplay // 开启自动播放
        
        mView.subviews.forEach { $0.removeFromSuperview() }
        mView.addSubview((mPlayer.view)!)
        mPlayer.view.snp.makeConstraints { (make) in
            make.size.equalTo(mView)
            make.edges.equalTo(mView)
        }
        //        let playerViewGesture = UITapGestureRecognizer(target: self, action: #selector(playerViewTag))
        //        mPlayer.view.addGestureRecognizer(playerViewGesture)
        
        initView()
        
        // net
        mIsNetLimited = netLimited
        if mIsNetLimited {
            setUpNet()
        }
        
    }
    
    func initView(){
        let playerViewGesture = UITapGestureRecognizer(target: self, action: #selector(playerViewTag))
        mView.addGestureRecognizer(playerViewGesture)
        initMediaControllerView()
        addMediaControllerConstraints()
    }
    
    func initMediaControllerView(){
        
        mBtnBack.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        
        mBtnPlay.addTarget(self, action: #selector(play), for: .touchUpInside)
        mBtnPause.addTarget(self, action: #selector(pause), for: .touchUpInside)
        mBtnFullScrean.addTarget(self, action: #selector(fullScreen), for: .touchUpInside)
        
        let controllerViewGesture = UITapGestureRecognizer(target: self, action: #selector(viewControllerTap))
        mViewController.addGestureRecognizer(controllerViewGesture)
        
        mSlider.addTarget(self, action: #selector(didSliderTouchDown), for: .touchDown)
        mSlider.addTarget(self, action: #selector(didSliderTouchCancel), for: .touchCancel)
        mSlider.addTarget(self, action: #selector(didSliderTouchUp), for: [.touchUpInside, .touchUpOutside])
        mSlider.addTarget(self, action: #selector(didSliderValueChanged), for: .valueChanged)
        
        
        mView.addSubview(mViewController)
        mViewController.addSubview(mTopBg)
        mViewController.addSubview(mBottomBg)
        mViewController.addSubview(mBtnBack)
        mViewController.addSubview(mBtnPlay)
        mViewController.addSubview(mBtnPause)
        mViewController.addSubview(mLabelTotalDuration)
        mViewController.addSubview(mLabelCurrentDuration)
        mViewController.addSubview(mCacheProgress)
        mViewController.addSubview(mSlider)
        mViewController.addSubview(mBtnFullScrean)
        mView.addSubview(mIVLoading)
        
        showInitState()
    }
    
    func addMediaControllerConstraints(){
        
        // mediacontroller
        mViewController.snp.makeConstraints { (make) in
            make.edges.equalTo(mView)
        }
        mTopBg.snp.makeConstraints { (make) in
            make.top.equalTo(mViewController)
            make.width.equalTo(mViewController)
            make.height.equalTo(40)
            make.left.equalTo(mViewController)
        }
        mBtnBack.snp.makeConstraints { (make) in
            make.left.equalTo(mViewController).offset(6)
            make.top.equalTo(mViewController).offset(2)
            make.width.height.equalTo(40)
        }
        mBtnPlay.snp.makeConstraints { (make) in
            make.center.equalTo(mViewController)
            make.height.width.equalTo(36)
        }
        mBtnPause.snp.makeConstraints { (make) in
            make.center.equalTo(mViewController)
            make.height.width.equalTo(36)
        }
        mBottomBg.snp.makeConstraints { (make) in
            make.bottom.equalTo(mViewController)
            make.width.equalTo(mViewController)
            make.height.equalTo(32)
            make.left.equalTo(mViewController)
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
        mCacheProgress.snp.makeConstraints { (make) in
            make.centerY.equalTo(mSlider).offset(1)
            make.left.equalTo(mSlider)
            make.right.equalTo(mSlider)
            make.height.equalTo(3)
        }
        //
        mIVLoading.snp.makeConstraints { (make) in
            make.center.equalTo(mViewController)
            make.height.width.equalTo(36)
        }
    }
    
    /// can override
    
    
    //-------------
    
    
    /// must override
    func setSmallConstraints(parentView: UIView){
        
    }
    
    //-----------------
    
    // 控制相关方法
    func backClick(){
        if mIsFull{
            exitFullscreen()
        }else{
            mDelegate?.backClick()
        }
    }
    
    public func slideTo(time: TimeInterval){
        mPlayer.currentPlaybackTime = time
        
        NSLog(DVideoManager.TAG, "slide to : \(time)")
    }
    
    /// 进度条 按下
    @objc private func didSliderTouchDown(){
        print("down")
        mBeginDragMediaSlider = true
    }
    /// 进度条 取消
    @objc private  func didSliderTouchCancel(){
        mBeginDragMediaSlider = false
        
    }
    /// 进度条 松开
    @objc private  func didSliderTouchUp(){
        mBeginDragMediaSlider = false
        
        showAndFade()
    }
    /// 进度条 值改变（被拖动）
    @objc private func didSliderValueChanged(){
        // 修改播放进度
        slideTo(time: TimeInterval(mSlider.value))
        
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
    
    // 播放状态方法
    /// 第一次进入的时候视频初始化：播放按钮无效
    func showInitState(){
        mBtnPlay.isHidden = true
        mBtnPause.isHidden = true
        mIVLoading.isHidden = false
        hideNetSpeed()
        mViewController.isHidden = false
    }
    
    func showPause(){
        mIVLoading.isHidden = true
        showNetSpeed()
        
    }
    
    func hideNetSpeed(){
        
    }
    
    func showNetSpeed(){
        
    }
    
    func showPlaying(){
        hideLoading()
        hideNetSpeed()
    }
    
    func showLoading(){
        mIVLoading.isHidden = false
    }
    
    func hideLoading(){
        mIVLoading.isHidden = true
    }
    //-----------
    
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
        showAndFade()
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
        // update cache progress
        
        NSLog(DVideoManager.TAG, "mPlayer.playableDuration:\(mPlayer.playableDuration)")
        let cachePercent = Float(mPlayer.playableDuration) / Float(intDuration)
        mCacheProgress.setProgress(cachePercent, animated: true)
        
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
            NSLog("\(DVideoManager.TAG) IJKMPMovieLoadState.playthroughOK ")
            break
        case IJKMPMovieLoadState.stalled:
            /// 网络差 自动停止
            NSLog("\(DVideoManager.TAG) IJKMPMovieLoadState.stalled ")
            showLoading()
            mDelegate?.loading()
            break
        case IJKMPMovieLoadState.playable:
            /// 缓冲结束可以播放
            NSLog("\(DVideoManager.TAG) playable ")
            
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
            NSLog("\(DVideoManager.TAG) IJKMPMovieFinishReasonPlaybackEnded ")
            break
        case IJKMPMovieFinishReason.userExited.rawValue:
            NSLog("\(DVideoManager.TAG) IJKMPMovieFinishReasonUserExited ")
            break
        case IJKMPMovieFinishReason.playbackError.rawValue:
            NSLog("\(DVideoManager.TAG) IJKMPMovieFinishReasonPlaybackError")
            break
        default:
            NSLog("\(DVideoManager.TAG) default ")
            break
        }
        mDelegate?.stop(playTime: mPlayer.currentPlaybackTime)
    }
    
    func mediaIsPreparedToPlayDidChange(notification: Notification){
        
    }
    
    /// 播放状态改变
    func moviePlayBackStateDidChange(notification: Notification){
        let state = mPlayer.playbackState
        switch (state){
        case IJKMPMoviePlaybackState.stopped:
            NSLog("\(DVideoManager.TAG)  IJKMPMoviePlaybackStateStopped ")
            break
        case IJKMPMoviePlaybackState.playing:
            NSLog("\(DVideoManager.TAG)  IJKMPMoviePlaybackStatePlaying  ")
            showPlaying()
            mDelegate?.play(playTime: mPlayer.currentPlaybackTime)
            break
        case IJKMPMoviePlaybackState.paused:
            NSLog("\(DVideoManager.TAG)  IJKMPMoviePlaybackStatePaused  ")
            showPause()
            mDelegate?.pause()
            break
        case IJKMPMoviePlaybackState.interrupted:
            NSLog("\(DVideoManager.TAG)  IJKMPMoviePlaybackStateInterrupted  ")
            
            break
        case IJKMPMoviePlaybackState.seekingForward:
            NSLog("\(DVideoManager.TAG) IJKMPMoviePlaybackStateSeekingForward ")
            break
        case IJKMPMoviePlaybackState.seekingBackward:
            NSLog("\(DVideoManager.TAG) IJKMPMoviePlaybackStateSeekingBackward ")
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
    
    
    /// 取消 屏幕旋转监听
    func removeScreenNotificationObservers(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    /// 开始 屏幕旋转监听
    func initScreenNotificationObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    // 屏幕是否是垂直
    var mPortrait = false
    
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
    var parentView: UIView? // 非全屏下的父控价
    var mPlayerViewFrame: CGRect?
    
    func enterFullScreen(_ orientationState: PlayerViewState){
        
        mPlayerViewState = .animating
        if parentView == nil{
            parentView = self.mView.superview!
        }
        
        mPlayerViewFrame = self.mView.frame
        
        // movieView 移到 window 上
        //        let rectInWindow = mPlayerView.convert(mPlayerView.bounds, to: UIApplication.shared.keyWindow)
        mView.removeFromSuperview()
        //        mPlayerView.frame = rectInWindow
        UIApplication.shared.keyWindow?.addSubview(mView)
        
        self.mView.updateConstraints()
        UIView.animate(withDuration: 0.5, animations: {
            /// 先设置 playerView 旋转角度为 0
            self.mView.transform = CGAffineTransform.init(rotationAngle: CGFloat(0))
            if orientationState == .fullScreenRight {
                if self.mScreenState != .fullScreenRight{
                    self.mView.transform = CGAffineTransform.init(rotationAngle: CGFloat(-Double.pi/2))
                }
            }else if orientationState == .fullScreenLeft{
                if self.mScreenState != .fullScreenLeft{
                    self.mView.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi/2))
                }
            }
            
            if self.mScreenState == .fullScreenLeft || self.mScreenState == .fullScreenRight{
                self.mView.snp.makeConstraints({ (make) in
                    make.center.equalTo(self.mView.superview!)
                    make.width.equalTo(self.mView.superview!.snp.width)
                    make.height.equalTo(self.mView.superview!.snp.height)
                })
                
            }else{
                self.mView.snp.makeConstraints({ (make) in
                    make.center.equalTo(self.mView.superview!)
                    make.width.equalTo(self.mView.superview!.snp.height)
                    make.height.equalTo(self.mView.superview!.snp.width)
                })
            }
            
            self.mView.layoutIfNeeded()
            
        }) { (finished) in
            self.mPlayerViewState = orientationState
            self.mIsFull = true
            self.mBtnFullScrean.setImage(UIImage(named: "jc_shrink"), for: .normal)
        }
    }
    
    func exitFullscreen(){
        if (self.mPlayerViewState != .fullScreenLeft && self.mPlayerViewState != .fullScreenRight) {
            return
        }
        
        self.mPlayerViewState = .animating
        
        self.mView.updateConstraints()
        UIView.animate(withDuration: 0.5, animations: {
            self.mView.transform = CGAffineTransform.init(rotationAngle: CGFloat(0))
            
            self.setSmallConstraints(parentView: self.mView.superview!)
            
            self.mView.layoutIfNeeded()
        }) { (finished) in
            self.mView.removeFromSuperview()
            self.parentView?.addSubview(self.mView)
            
            self.setSmallConstraints(parentView: self.parentView!)
            
            self.mView.layoutIfNeeded()
            self.mPlayerViewState = .small
            self.mIsFull = false
            self.mBtnFullScrean.setImage(UIImage(named: "jc_enlarge"), for: .normal)
        }
    }
    //-------
    
    static func fromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
}

