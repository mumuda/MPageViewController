//
//  MMTitleView.swift
//  MMPageViewControler
//
//  Created by 祝丹 on 2017/7/14.
//  Copyright © 2017年 祝丹. All rights reserved.
//

import UIKit

// 不继承有问题，继承NSObjectProtocol太臃肿
protocol MMTitleViewDelegate: class {
    func titleView(_ titleView: MMTitleView,targetIndex: Int)
}

class MMTitleView: UIView {
    // MARK: 对外属性
    weak var delegate: MMTitleViewDelegate?
    
    // MARK: 定义属性
    fileprivate var titles:[String]
    fileprivate var style: MMTitleStyle
    fileprivate lazy var currentIndex: Int = 0
    
    // MARK: 存储属性
    fileprivate lazy var titleLabels: [UILabel] = [UILabel]()
    
    // MARK: 控件属性
    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        return scrollView
    }()
    
    fileprivate lazy var splitLineView : UIView = {
        let splitView = UIView()
        splitView.backgroundColor = UIColor.lightGray
        let h : CGFloat = 0.5
        splitView.frame = CGRect(x: 0, y: self.frame.height - h, width: self.frame.width, height: h)
        return splitView
    }()
    
    fileprivate lazy var bottomLine: UIView = {
       let bottomLine = UIView()
        bottomLine.backgroundColor = self.style.scrollLineColor
        bottomLine.frame.size.height = self.style.scrollLineHeight
        bottomLine.frame.origin.y = self.bounds.height - self.style.scrollLineHeight
        return bottomLine
    }()
    
    fileprivate lazy var coverView : UIView = {
        let coverView = UIView()
        coverView.backgroundColor = self.style.coverBgColor
        coverView.alpha = 0.7
        return coverView
    }()
    
    init(frame: CGRect, titles: [String], style: MMTitleStyle) {
        self.titles = titles
        self.style = style

        super.init(frame: frame)
        setupUI() 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MMTitleView {
    fileprivate func setupUI() {
        // 将scrollView 添加到view中
        addSubview(scrollView)
        
        // 2.添加底部分割线
        addSubview(splitLineView)
        
        // 将titleLabel 添加到scrollview中
        setupTitleLabel()
        
        // 设置titleLabel 的frame
        setupTitleLabelFrame()
        
        // 添加滚动条
        if style.isShowScrollLine == true {
            setupBottomLine()
        }
        
        // 6.设置遮盖的View
        if style.isShowCover {
            setupCoverView()
        }
    }
    
    private func setupTitleLabel() {
        for (i,title) in titles.enumerated() {
            let titleLabel = UILabel()
            
            titleLabel.text = title
            titleLabel.font = UIFont.systemFont(ofSize: style.fonSize)
            titleLabel.textAlignment = .center
            titleLabel.tag = i
            titleLabel.textColor = i == 0 ? style.selectColor : style.normalColor
            
            scrollView.addSubview(titleLabel)
            titleLabels.append(titleLabel)
            
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(titleLabelClick(_:)))
            titleLabel.addGestureRecognizer(tapGes)
            
            titleLabel.isUserInteractionEnabled = true
        }
    }
    
    private func setupTitleLabelFrame() {
        
        let count = titles.count
        var w: CGFloat = 0
        let h: CGFloat = bounds.height
        var x: CGFloat = 0
        let y: CGFloat = 0
        
        for (i,label) in titleLabels.enumerated() {

            if  style.isScrollEnable {
                // 可以滚动
                w = (titles[i] as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: label.font], context: nil).width
                if i == 0 {
                    x = style.itemMargin/2
                } else {
                    x = titleLabels[i-1].frame.maxX + style.itemMargin
                }
            } else {
                // 不能滚动
                w = bounds.width / CGFloat(count)
                x = w * CGFloat(i)
            }
            
            label.frame = CGRect(x: x, y: y, width: w, height: h)
            
            // 放大的代码
            if i == 0 {
                let scale = style.isNeedScale ? style.scaleRange : 1.0
                label.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
        
        if style.isScrollEnable {
            let maxW: CGFloat = style.isScrollEnable ? (titleLabels.last!.frame.maxX + style.itemMargin/2) : 0
            scrollView.contentSize = CGSize(width: maxW, height: 0)
        }
    }
    
    fileprivate func setupBottomLine() {
        scrollView.addSubview(bottomLine)
        bottomLine.frame = titleLabels.first!.frame
        bottomLine.frame.size.height = style.scrollLineHeight
        bottomLine.frame.origin.y = bounds.height - style.scrollLineHeight
    }
    
    fileprivate func setupCoverView() {
        scrollView.insertSubview(coverView, at: 0)
        let firstLabel = titleLabels[0]
        var coverW = firstLabel.frame.width
        let coverH = style.coverH
        var coverX = firstLabel.frame.origin.x
        let coverY = (bounds.height - coverH) * 0.5
        
        if style.isScrollEnable {
            coverX -= style.coverMargin
            coverW += style.coverMargin * 2
        }
        coverView.frame = CGRect(x: coverX, y: coverY, width: coverW, height: coverH)
        
        coverView.layer.cornerRadius = style.coverRadius
        coverView.layer.masksToBounds = true
    }
}

// MARK: - Action&Private Method
extension MMTitleView {
    @objc fileprivate func titleLabelClick(_ tapGes: UITapGestureRecognizer) {
        guard let targetLabel = tapGes.view as? UILabel else { return }

        // 1.如果是重复点击同一个Title,那么直接返回
        if targetLabel.tag == currentIndex { return }
        
        // 调整title
        adjustTItleLabel(targetIndex: targetLabel.tag)
        
        // 通知ContentView进行调整
        delegate?.titleView(self, targetIndex: currentIndex)
        
        // 调整bottomLine
        if style.isShowScrollLine == true {
            UIView.animate(withDuration: 0.25, animations: { 
                self.bottomLine.frame.origin.x = targetLabel.frame.origin.x
                self.bottomLine.frame.size.width = targetLabel.frame.size.width
            })
        }
    }
    
    fileprivate func adjustTItleLabel(targetIndex:Int) {
        
        if targetIndex == currentIndex {
            return
        }
        
        // 取出目标label
        let targetLabel = titleLabels[targetIndex]
        let sourceLabel = titleLabels[currentIndex]
        
        targetLabel.textColor = style.selectColor
        sourceLabel.textColor = style.normalColor
        
        currentIndex = targetIndex
        
        // 调整位置
        if style.isScrollEnable == true {
            var offSet = targetLabel.center.x - scrollView.bounds.width/2
            if offSet < 0 {
                offSet = 0
            }else if offSet > scrollView.contentSize.width - scrollView.bounds.width {
                offSet = scrollView.contentSize.width - scrollView.bounds.width
            }
            scrollView.setContentOffset(CGPoint(x: offSet, y: 0), animated: true)
            
        }

        // 调整字体比例
        if style.isNeedScale {
            sourceLabel.transform = CGAffineTransform.identity
            targetLabel.transform = CGAffineTransform(scaleX: style.scaleRange, y: style.scaleRange)
        }
        
        // 遮盖移动
        if style.isShowCover {
            let coverX = style.isScrollEnable ? (targetLabel.frame.origin.x - style.coverMargin) : targetLabel.frame.origin.x
            let coverW = style.isScrollEnable ? (targetLabel.frame.width + style.coverMargin * 2) : targetLabel.frame.width
            UIView.animate(withDuration: 0.15, animations: {
                self.coverView.frame.origin.x = coverX
                self.coverView.frame.size.width = coverW
            })
        }
    }
}

// MARK: - MMContentViewDelegate
extension MMTitleView: MMContentViewDelegate {
    func contentView(_ contentView: MMContentView, targetIndex: Int) {
        adjustTItleLabel(targetIndex: targetIndex)
    }
    
    func contentView(_ contentView: MMContentView, targetIndex: Int, progress: CGFloat) {
        // 取出目标label
        let targetLabel = titleLabels[targetIndex]
        let sourceLabel = titleLabels[currentIndex]
        
        // 2.颜色渐变
        let deltaRGB = UIColor.getRGBDelta(firstColor: style.selectColor, secondColor: style.normalColor)
        let selectedRGB = style.selectColor.getRGB()
        let normalRGB = style.normalColor.getRGB()
        
        targetLabel.textColor = UIColor.init(r: normalRGB.0 + deltaRGB.0 * progress , g: normalRGB.1 + deltaRGB.1 * progress, b: normalRGB.2 + deltaRGB.2 * progress)
        sourceLabel.textColor = UIColor.init(r: selectedRGB.0 - deltaRGB.0 * progress , g: selectedRGB.1 - deltaRGB.1 * progress, b: selectedRGB.2 - deltaRGB.2 * progress)
        
        
        let deltaX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x
        let deltaW = targetLabel.frame.width - sourceLabel.frame.width
        // 底部bottomLine的渐变过程
        if style.isShowScrollLine == true {
            
            bottomLine.frame.origin.x = sourceLabel.frame.origin.x + deltaX * progress
            bottomLine.frame.size.width = sourceLabel.frame.width + deltaW * progress
        }
        
        // 6.放大的比例
        if style.isNeedScale {
            let scaleDelta = (style.scaleRange - 1.0) * progress
            sourceLabel.transform = CGAffineTransform(scaleX: style.scaleRange - scaleDelta, y: style.scaleRange - scaleDelta)
            targetLabel.transform = CGAffineTransform(scaleX: 1.0 + scaleDelta, y: 1.0 + scaleDelta)
        }
        
        // 7.计算cover的滚动
        if style.isShowCover {
            coverView.frame.size.width = style.isScrollEnable ? (sourceLabel.frame.width + 2 * style.coverMargin + deltaW * progress) : (sourceLabel.frame.width + deltaW * progress)
            coverView.frame.origin.x = style.isScrollEnable ? (sourceLabel.frame.origin.x - style.coverMargin + deltaX * progress) : (sourceLabel.frame.origin.x + deltaX * progress)
        }
    }
}
