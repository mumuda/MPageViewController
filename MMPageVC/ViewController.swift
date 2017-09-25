//
//  ViewController.swift
//  MMPageVC
//
//  Created by 祝丹 on 2017/8/2.
//  Copyright © 2017年 祝丹. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
//        let titles = ["木木","豆豆","胖胖","瘦瘦","啦啦","妮妮"]
        let titles = ["木木","豆豆豆","胖胖","瘦啊瘦","啦啦奋斗史","妮妮","木木","豆豆豆","胖胖","瘦啊瘦","啦啦奋斗史","妮妮"]
        let titleStyle = MMTitleStyle()
        titleStyle.titleHeight = 50
        titleStyle.isScrollEnable = true
        titleStyle.isShowScrollLine = true
        titleStyle.isNeedScale = true
        titleStyle.isShowCover = true
        
        var childVc = [UIViewController]()
        for _ in titles {
            let vc = UIViewController()
            vc.view.backgroundColor = UIColor.randomColor()
            childVc.append(vc)
        }
        
        let pageViewFram = CGRect(x: 0, y: 64 , width: view.frame.width, height: view.frame.height - 64)
        
        let pageView = MMPageView(frame: pageViewFram, titles: titles, childVc: childVc, parentVc: self,style: titleStyle)
        
        view.addSubview(pageView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

