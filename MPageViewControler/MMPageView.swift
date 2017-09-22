//
//  MMPageView.swift
//  MMPageViewControler
//
//  Created by 祝丹 on 2017/7/14.
//  Copyright © 2017年 祝丹. All rights reserved.
//

import UIKit



class MMPageView: UIView {

    fileprivate var titles: [String]
    fileprivate var childVc: [UIViewController]
    fileprivate var parentVc: UIViewController
    fileprivate var style:MMTitleStyle!
    
    // ?.取到的类型一定是可选型
    fileprivate var titleView: MMTitleView!
    fileprivate var contentView: MMContentView!
    
    init(frame: CGRect, titles: [String], childVc: [UIViewController], parentVc: UIViewController,style: MMTitleStyle) {
        
        assert(titles.count == childVc.count, "标题&控制器个数不同,请检测!!!")
        self.titles = titles
        self.childVc = childVc
        self.parentVc = parentVc
        self.style = style
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI
extension MMPageView {
    fileprivate func setupUI() {
        setupTitleView()
        setupContentView()
    }
    
    private func setupTitleView() {
        let titleFrame = CGRect(x: 0, y: 0, width: bounds.width, height: style.titleHeight)
        titleView = MMTitleView(frame: titleFrame, titles: titles,style: style)
        titleView.backgroundColor = UIColor.randomColor()
        
        addSubview(titleView)

    }
    
    private func setupContentView() {
        let contentFrame = CGRect(x: 0, y: titleView.frame.maxY, width: bounds.width, height: bounds.height - titleView.frame.height)
        contentView = MMContentView(frame: contentFrame, childVc: childVc, parentVc: parentVc)
        contentView.backgroundColor = UIColor.randomColor()
        contentView.delegate = titleView
        addSubview(contentView)
        
        titleView.delegate = contentView
    }
}
