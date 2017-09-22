//
//  MMTitleStyle.swift
//  MMPageViewControler
//
//  Created by 祝丹 on 2017/7/18.
//  Copyright © 2017年 祝丹. All rights reserved.
//

import UIKit
// 结构体是值类型，存储在栈里，存取效率特别高，堆的内存大，栈的内存小，栈里存太多就会栈溢出，闪退
//static MMTitleStyle {
//
//}

// 不集成也会非常轻量级
class MMTitleStyle {
    var titleHeight: CGFloat = 44
    
    /// 普通Title颜色
    var normalColor: UIColor = UIColor.init(r: 0, g: 0, b: 0)
    /// 选中Title颜色
    var selectColor: UIColor = UIColor.init(r: 255, g: 127, b: 0)
    /// Title字体大小
    var fonSize: CGFloat = 15
    /// 是否是滚动的Title
    var isScrollEnable: Bool = false
    /// 滚动Title的字体间距
    var itemMargin: CGFloat = 30
    
    
    /// 是否显示底部滚动条
    var isShowScrollLine: Bool = false
    /// 底部滚动条的颜色
    var scrollLineHeight: CGFloat = 2
    /// 底部滚动条的高度
    var scrollLineColor: UIColor = .orange
    
    /// 是否进行缩放
    var isNeedScale: Bool = false
    /// 缩放比例
    var scaleRange : CGFloat = 1.2
    
    
    /// 是否显示遮盖
    var isShowCover : Bool = false
    /// 遮盖背景颜色
    var coverBgColor : UIColor = UIColor.lightGray
    /// 文字&遮盖间隙
    var coverMargin : CGFloat = 5
    /// 遮盖的高度
    var coverH : CGFloat = 25
    /// 设置圆角大小
    var coverRadius : CGFloat = 12
}
