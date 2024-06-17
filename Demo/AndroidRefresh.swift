//
//  AndroidRefresh.swift
//  Demo
//
//  Created by 赵江明 on 2024/6/17.
//  Copyright © 2024 赵江明. All rights reserved.
//

import Foundation
import UIKit

// 枚举和结构体定义
enum PullState {
    case ready, dragging, refreshing, finished
}

class AndroidRefresh: UIControl {
    // 私有属性转换
    private var initConstraits: UInt32 = 0
    private var topConstrait: NSLayoutConstraint?
    private var panView: UIView?
    private var pathLayer = CAShapeLayer()
    private var arrowLayer = CAShapeLayer()
    private var view = UIView()
    private var container = UIView()
    private var marginTop: CGFloat = 0
    private var isDragging: Bool = false
    private var isFullyPulled: Bool = false
    private var pullState: PullState = .ready
    private var colorIndex: Int = 0
    private var firstMoveY: CGFloat = 0
    private var offsetMinY: CGFloat = 0
    
    private var move: CGPoint = .zero
    
    var colors: [UIColor] = [UIColor.red, UIColor.blue, UIColor.green]
    
    private var refreshStartY: CGFloat = -60
    lazy var refreshingY: CGFloat = NavigationBarHeightUtil.getCurrentNavigationBarHeight() + 10
    private lazy var refreshEndY: CGFloat = NavigationBarHeightUtil.getCurrentNavigationBarHeight() + 60
    
    // 初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = UIColor.clear
        layer.opacity = 0
        
        // 创建视图
        view.addSubview(container)
        
        // 设置属性和约束
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // 约束设置代码
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 40),
            container.heightAnchor.constraint(equalToConstant: 40),
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.layer.backgroundColor = UIColor.white.cgColor
        view.layer.cornerRadius = 20
        
        view.layer.shadowOffset = CGSize(width: 0, height: 0.7)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 1.0
        view.layer.shadowOpacity = 0.12
        
        // 初始化pathLayer
        pathLayer.strokeStart = 0
        pathLayer.strokeEnd = 10
        pathLayer.fillColor = nil
        pathLayer.lineWidth = 2.5
        container.layer.addSublayer(pathLayer)
        
        // 创建路径和箭头的UIBezierPath
        let path = UIBezierPath(arcCenter: CGPoint(x: 20, y: 20),
                                radius: 9,
                                startAngle: 0,
                                endAngle: 2 * CGFloat.pi,
                                clockwise: true)
        pathLayer.path = path.cgPath
        pathLayer.strokeStart = 1
        pathLayer.strokeEnd = 1
        pathLayer.lineCap = .square
        
        // 初始化arrowLayer
        arrowLayer.strokeStart = 0
        arrowLayer.strokeEnd = 1
        arrowLayer.fillColor = nil
        arrowLayer.lineWidth = 3
        arrowLayer.strokeColor = UIColor.blue.cgColor
        let arrowPath = AndroidRefresh.bezierArrow(from: CGPoint(x: 20, y: 20),
                                                   to: CGPoint(x: 20, y: 21),
                                                   width: 1)
        arrowLayer.path = arrowPath.cgPath
        arrowLayer.transform = CATransform3DMakeTranslation(8.5, 0, 0)
        
        container.layer.addSublayer(pathLayer)
        container.layer.addSublayer(arrowLayer)
        
        // 设置锚点
        let anchor = CGPoint(x: 0.5, y: 0.5)
        setAnchorPoint(anchor, forView: container)
        
        addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 40),
            view.heightAnchor.constraint(equalToConstant: 40),
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 40),
            heightAnchor.constraint(equalToConstant: 40)
        ])
    }
        
    // 自定义初始化器，使用UIScrollView初始化
    convenience init(panView: UIView, target: Any?, refreshSel: Selector) {
        self.init(frame: .zero)
        
        setup()
        
        self.panView = panView
        
        if let scrollView = panView as? UIScrollView {
            scrollView.bounces = false
        }
            
        // 拖动手势
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        panGestureRecognizer.delegate = self
        panView.addGestureRecognizer(panGestureRecognizer)
        
        addTarget(target, action: refreshSel, for: .valueChanged)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if superview == nil {
            return
        }
        
        // 确保只执行一次设置约束的代码
        AndroidRefresh.once(token: &initConstraits) {
            // 假设有一个方法来配置约束
            self.setupConstraints()
        }
    }

    private func setupConstraints() {
        // 假设父视图已经被设置
        guard let superview = superview else { return }
        
        // 设置居中和固定高度约束
        topConstrait = topAnchor.constraint(equalTo: superview.topAnchor)
        let centerXConstrait = centerXAnchor.constraint(equalTo: superview.centerXAnchor)
        
        // 设置新的约束
        translatesAutoresizingMaskIntoConstraints = false
        
        self.superview?.addConstraint(topConstrait!)
        self.superview?.addConstraint(centerXConstrait)
    }
        
    // 模拟dispatch_once的行为
    private static var onceTokens = [UInt32]()
        
    private static func once(token: inout UInt32, block: () -> Void) {
        if token == 0 {
            token = 1 // 模拟一次性标记
            block()
        }
    }
        
    // 静态方法，用于创建箭头的UIBezierPath
    static func bezierArrow(from startPoint: CGPoint, to endPoint: CGPoint, width: CGFloat) -> UIBezierPath {
        let length = sqrt(pow(endPoint.x - startPoint.x, 2) + pow(endPoint.y - startPoint.y, 2))
        let points = getAxisAlignedArrowPoints(width: width, length: length)
          
        let transform = transformForStartPoint(startPoint, endPoint: endPoint, length: length)
          
        let path = UIBezierPath()
        path.move(to: points[0].applying(transform))
        path.addLine(to: points[1].applying(transform))
        path.addLine(to: points[2].applying(transform))
        path.close()
          
        return path
    }
      
    // 辅助方法，用于获取箭头的三个点
    static func getAxisAlignedArrowPoints(width: CGFloat, length: CGFloat) -> [CGPoint] {
        return [
            CGPoint(x: 0, y: width),
            CGPoint(x: length, y: 0),
            CGPoint(x: 0, y: -width)
        ]
    }
        
    static func transformForStartPoint(_ startPoint: CGPoint, endPoint: CGPoint, length: CGFloat) -> CGAffineTransform {
        let cosine = (endPoint.x - startPoint.x) / length
        let sine = (endPoint.y - startPoint.y) / length
            
        return CGAffineTransform(cosine, sine, -sine, cosine, startPoint.x, startPoint.y)
    }
}

// UIGestureRecognizerDelegate 方法
extension AndroidRefresh: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func setMarginTop(_ topMargin: CGFloat) {
        marginTop = -topMargin
        layoutIfNeeded()
    }
    
    func setAnchorPoint(_ anchorPoint: CGPoint, forView view: UIView) {
        let oldOrigin = view.frame.origin
        view.layer.anchorPoint = anchorPoint
        let newOrigin = view.frame.origin
        
        let transition = CGPoint(x: newOrigin.x - oldOrigin.x, y: newOrigin.y - oldOrigin.y)
        view.center = CGPoint(x: view.center.x - transition.x, y: view.center.y - transition.y)
    }
    
    @objc func panAction(_ sender: UIPanGestureRecognizer) {
        guard pullState != .refreshing else { return }
        
        move = sender.translation(in: sender.view)
        switch sender.state {
        case .began:
            firstMoveY = move.y
            if let scrollView = panView as? UIScrollView {
                offsetMinY = min(scrollView.contentOffset.y, offsetMinY)
            }
        case .changed:
            move.y = (move.y - firstMoveY) * -0.75
            
            isDragging = true
            pullState = .dragging
           
            draggingView(move)
        case .ended:
            if pullState != .dragging {
                return
            }
            
            isDragging = false
            if isFullyPulled {
                pullState = .refreshing
                startRefreshing()
            } else {
                resetToStartPosition()
            }
        default:
            break
        }
    }
        
    func draggingView(_ offset: CGPoint) {
        // 确保只有在刷新状态不是已经开始时才处理
        guard pullState != .refreshing else { return }
            
        let newY = -offset.y - 50.0 // 根据拖动偏移更新Y值，50是示例值
            
        // 判断是否达到最大拖动距离
        if offset.y - marginTop > -refreshEndY {
            // 如果没有达到最大拖动距离，更新pathLayer和arrowLayer的颜色
            isFullyPulled = false
            pathLayer.strokeColor = colors[colorIndex].cgColor
            arrowLayer.strokeColor = colors[colorIndex].cgColor
                
            // 更新旋转角度和透明度
            draggingAnimating(with: offset, outside: false)
            
            if isDragging {
                // 更新顶部约束
                topConstrait?.constant = newY
                superview?.layoutIfNeeded() // 通知父视图进行布局更新
            }
        } else {
            // 如果达到最大拖动距离，处理完全拉动的状态
            isFullyPulled = true
            // 这里可以添加额外的动画或逻辑处理
            draggingAnimating(with: offset, outside: true)
        }
    }
    
    private func startRefreshing() {
        // 刷新开始的动画和逻辑
        UIView.animate(withDuration: 0.2) {
            self.topConstrait?.constant = self.refreshingY - self.marginTop
            self.superview?.layoutIfNeeded()
        }
        
        // 发送值改变事件，通知刷新开始
        startAnimating()
        sendActions(for: .valueChanged)
    }
        
    private func resetToStartPosition() {
        // 重置到起始位置的动画和逻辑
        // 动画回到起始位置
        UIView.animate(withDuration: 0.2, animations: {
            // 将top约束常数重置为初始刷新Y值，减去marginTop
            self.topConstrait?.constant = self.refreshStartY - self.marginTop
            // 通知父视图布局子视图
            self.superview?.layoutIfNeeded()
        }) { finished in
            // 动画完成后的回调
            if finished {
                // 这里可以添加动画完成后需要执行的代码
                self.pathLayer.strokeColor = self.colors[self.colorIndex].cgColor
            }
        }
    }
    
    func draggingAnimating(with point: CGPoint, outside: Bool) {
        let angle = -(point.y - marginTop) / 130
        // let angle = (point.y - marginTop - refreshStartY) / 130
        container.layer.transform = CATransform3DMakeRotation(angle * 10, 0, 0, 1)
            
        if !outside, pullState == .dragging {
            showView()
                
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            pathLayer.strokeStart = 1 - angle
            layer.opacity = Float(angle * 2.0)
            CATransaction.commit()
        }
    }
    
    func startAnimating() {
        // 旋转动画
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = 2 * Double.pi
        rotationAnimation.duration = 1.5
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.isRemovedOnCompletion = false
        container.layer.add(rotationAnimation, forKey: "ROTATE_ANIMATION")
            
        // 描边开始动画
        let beginHeadAnimation = CABasicAnimation(keyPath: "strokeStart")
        beginHeadAnimation.fromValue = 0.25
        beginHeadAnimation.toValue = 1.0
        beginHeadAnimation.duration = 0.5
        beginHeadAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
        // 描边结束动画
        let beginTailAnimation = CABasicAnimation(keyPath: "strokeEnd")
        beginTailAnimation.fromValue = 1.0
        beginTailAnimation.toValue = 1.0
        beginTailAnimation.duration = 0.5
        beginTailAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
        // 结束动画
        let endHeadAnimation = CABasicAnimation(keyPath: "strokeStart")
        endHeadAnimation.beginTime = 0.5
        endHeadAnimation.fromValue = 0.0
        endHeadAnimation.toValue = 0.25
        endHeadAnimation.duration = 1.0
        endHeadAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
        let endTailAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endTailAnimation.beginTime = 0.5
        endTailAnimation.fromValue = 0.0
        endTailAnimation.toValue = 1.0
        endTailAnimation.duration = 1.0
        endTailAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
        // 动画组合
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.5
        animationGroup.repeatCount = .infinity
        animationGroup.isRemovedOnCompletion = false
        animationGroup.animations = [beginHeadAnimation, beginTailAnimation, endHeadAnimation, endTailAnimation]
            
        // 添加动画到pathLayer
        pathLayer.add(animationGroup, forKey: "STROKE_ANIMATION")
            
        // 如果需要周期性改变颜色
        let timer = AndroidTimer.scheduledTimer(withTimeInterval: 0.5, target: self, selector: #selector(changeColor), userInfo: nil, repeats: false)
        RunLoop.current.add(timer, forMode: .common)
    }
    
    @objc func changeColor() {
        hideArrow()
            
        guard pullState == .refreshing else { return }
            
        colorIndex += 1
        if colorIndex >= colors.count {
            colorIndex = 0
        }
            
        let newColor = colors[colorIndex]
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        pathLayer.strokeColor = newColor.cgColor
        CATransaction.commit()
         
        let timer = AndroidTimer.scheduledTimer(withTimeInterval: 1.5, target: self, selector: #selector(changeColor), userInfo: nil, repeats: false)
        RunLoop.current.add(timer, forMode: .common)
    }
    
    func hideArrow() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        arrowLayer.opacity = 0
        CATransaction.commit()
    }
        
    func showArrow() {
        arrowLayer.opacity = 1
    }
    
    func endAnimating() {
        container.layer.removeAnimation(forKey: "ROTATE_ANIMATION")
        pathLayer.removeAnimation(forKey: "STROKE_ANIMATION")
    }
    
    func showView() {
        layer.transform = CATransform3DMakeScale(1, 1, 1)
        showArrow()
    }
        
    func hideView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.layer.opacity = 0
            self.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
            self.layoutIfNeeded()
        }, completion: { _ in
            self.endAnimating()
            
            self.pullState = .finished
            self.colorIndex = 0
            self.pathLayer.strokeColor = self.colors[self.colorIndex].cgColor
            self.topConstrait?.constant = self.refreshStartY + self.marginTop
        })
    }
    
    func startRefresh() {
        // 调用已有的开始刷新动画逻辑
        startRefreshWithRefreshY(refreshingY - marginTop)
    }
        
    func endRefresh() {
        hideView()
    }
    
    func startRefreshWithRefreshY(_ refreshingY: CGFloat) {
        pullState = .refreshing
        topConstrait?.constant = refreshingY - marginTop
            
        // 初始设置为缩放0，然后立即通过layoutIfNeeded更新布局
        layer.transform = CATransform3DMakeScale(0, 0, 1)
        layoutIfNeeded()

        // 使用UIView动画来改变透明度和缩放
        UIView.animate(withDuration: 0.6, animations: {
            self.layer.opacity = 1
            // 动画结束时视图恢复到正常大小
            self.layer.transform = CATransform3DIdentity
        }) { _ in
            // 动画完成后的回调
        }
            
        // 隐藏箭头，开始动画
        hideArrow()
        startAnimating()
            
        // 发送值改变事件，可能用于通知刷新状态的改变
        sendActions(for: .valueChanged)
    }
}
