//
//  MMContentView.swift
//  MMPageViewControler
//
//  Created by 祝丹 on 2017/7/14.
//  Copyright © 2017年 祝丹. All rights reserved.
//

import UIKit

/// self. 不能省略的情况
/// 1.在方法中和凄然标识有歧义（重名）
/// 2.在闭包（block）中self. 也不能省略

protocol MMContentViewDelegate: class {
    func contentView(_ contentView: MMContentView, targetIndex: Int)
    func contentView(_ contentView: MMContentView, targetIndex: Int,progress: CGFloat)
}


private let mContentCellID = "mContentCellID"
class MMContentView: UIView {
    // MARK: 对外属性
    weak var delegate: MMContentViewDelegate?
    
    // MARK: 定义属性
    fileprivate var childVcs: [UIViewController]
    fileprivate var parentVC: UIViewController
    fileprivate var startOffX: CGFloat = 0
    fileprivate var isForbidScroll: Bool = false
    
    // MARK: 控件属性
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }()
    
    // MARK: 构造函数
    init(frame: CGRect, childVc: [UIViewController], parentVc: UIViewController) {
        self.childVcs = childVc
        self.parentVC = parentVc
        super.init(frame: frame)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: mContentCellID)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension MMContentView {
    fileprivate func setupUI() {
        // 将所有子控制器添加到父控制器中
        for childVc in childVcs {
            parentVC.addChildViewController(childVc)
        }
        addSubview(collectionView)
    }
}

extension MMContentView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVcs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mContentCellID, for: indexPath)
        
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        let childVc = childVcs[indexPath.item]
        childVc.view.frame = cell.contentView.bounds
        cell.contentView.addSubview(childVc.view)
        return cell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isForbidScroll = false
        startOffX = scrollView.contentOffset.x
    }
    
    // 停止减速
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard !isForbidScroll else { return }
        contentEndScroll()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !isForbidScroll else { return }
        if decelerate == false {
            contentEndScroll()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 判断和开始值是否一致
        guard startOffX != scrollView.contentOffset.x,
            !isForbidScroll else {
            return
        }
        
        var targetIndex = 0

        var progress: CGFloat = 0.0
        
        // 赋值
        let currentIndex = Int(startOffX / scrollView.bounds.width)
        if startOffX < scrollView.contentOffset.x { // 左滑动
            targetIndex = currentIndex + 1
            targetIndex = targetIndex > (childVcs.count - 1) ? (childVcs.count - 1) :targetIndex
            
            progress = (scrollView.contentOffset.x - startOffX) / scrollView.bounds.width
        } else { // 右滑动
            targetIndex = currentIndex - 1
            targetIndex = targetIndex < 0 ? 0 : targetIndex
            
            progress = (startOffX - scrollView.contentOffset.x) / scrollView.bounds.width
        }
        
        // 通知代理
        delegate?.contentView(self, targetIndex: targetIndex, progress: progress)
    }
    
    
    
    private func contentEndScroll() {
        // 获取滚动的位置
        let currentIndex = Int(collectionView.contentOffset.x / collectionView.bounds.width)
        
        // 通知titleView进行调整
        delegate?.contentView(self, targetIndex: currentIndex)
    }
}

// MARK: - MMTitleViewDelegate
extension MMContentView: MMTitleViewDelegate {
    func titleView(_ titleView: MMTitleView, targetIndex: Int) {
        isForbidScroll = true
        let indexPath = IndexPath(item: targetIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        
    }
}
