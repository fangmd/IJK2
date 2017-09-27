//
//  ViewController.swift
//  IJKDemo
//
//  Created by nercdev on 2017/6/12.
//  Copyright © 2017年 北京泛在时代教育技术有限责任公司. All rights reserved.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    // MainViewController 拥有 action， action 拥有 navigation， navigation 拥有 MainViewCOn
    
    
    let mBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Controller", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        return btn
    }()
    
    let mBtn2: UIButton = {
        let btn = UIButton()
        btn.setTitle("Package", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        return btn
    }()
    
    let mBtn3: UIButton = {
        let btn = UIButton()
        btn.setTitle("Net Dialog", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        mBtn.addTarget(self, action: #selector(toController), for: .touchUpInside)
        mBtn2.addTarget(self, action: #selector(toController2), for: .touchUpInside)
        mBtn3.addTarget(self, action: #selector(showNetDialog), for: .touchUpInside)
        
        self.view.addSubview(mBtn)
        self.view.addSubview(mBtn2)
        self.view.addSubview(mBtn3)
        
        
        mBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(64)
            make.width.equalTo(self.view)
            make.height.equalTo(30)
        }
        
        mBtn2.snp.makeConstraints { (make) in
            make.top.equalTo(mBtn.snp.bottom).offset(20)
            make.width.equalTo(self.view)
            make.height.equalTo(30)
        }
        
        mBtn3.snp.makeConstraints { (make) in
            make.top.equalTo(mBtn2.snp.bottom).offset(20)
            make.width.equalTo(self.view)
            make.height.equalTo(30)
        }
    }
    
    func toController(){        
        navigationController?.pushViewController(MediaControllerViewController(), animated: true)
    }
    
    func toController2(){
        navigationController?.pushViewController(DemoViewControler(), animated: true)
    }
    
    func showNetDialog(){
        let dialog = UIAlertController(title: "提示", message: "当前使用的是移动网络，是否继续播放视频?", preferredStyle: UIAlertControllerStyle.alert)
        dialog.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.destructive, handler: { (action) in
            NSLog("OK")
        }))
        
        dialog.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: { (action) in
            NSLog("Cancel")
        }))
        
        present(dialog, animated: true) { 
            NSLog("dialog show")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //shouldAutorotateToInterfaceOrientation
    
    
    
}

