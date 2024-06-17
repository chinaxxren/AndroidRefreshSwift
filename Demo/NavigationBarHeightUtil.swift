//
//  NavigationBarHeightUtil.swift
//  Demo
//
//  Created by 赵江明 on 2024/6/17.
//  Copyright © 2024 赵江明. All rights reserved.
//

import UIKit

class NavigationBarHeightUtil {
    /// 获取当前 UINavigationBar 的高度
    /// - Returns: 返回导航栏的高度，如果没有导航栏则返回 0
    static func getCurrentNavigationBarHeight() -> CGFloat {
        // 尝试获取根视图控制器
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            // 尝试获取当前显示的视图控制器
            let topViewController = topViewController(in: rootViewController)
            return getNavigationBarHeight(for: topViewController)
        }
        
        // 如果没有找到视图控制器或导航栏，返回 0
        return 0.0
    }
    
    /// 辅助方法，递归查找当前显示的视图控制器
    private static func topViewController(in viewController: UIViewController) -> UIViewController {
        if let presented = viewController.presentedViewController {
            return topViewController(in: presented)
        } else if let navigationController = viewController as? UINavigationController {
            return topViewController(in: navigationController.visibleViewController!)
        } else if let tabController = viewController as? UITabBarController, let selected = tabController.selectedViewController {
            return topViewController(in: selected)
        } else {
            return viewController
        }
    }
    
    /// 辅助方法，获取导航栏高度
    private static func getNavigationBarHeight(for viewController: UIViewController) -> CGFloat {
        guard let navigationBar = viewController.navigationController?.navigationBar else {
            return 0.0
        }
        
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            if let windowScene = scenes.first as? UIWindowScene {
                let windows = windowScene.windows
                // 通常使用第一个窗口或特定逻辑来选择窗口
                let currentWindow = windows.first
                // 现在你可以使用 currentWindow 作为当前场景的窗口
                statusBarHeight = currentWindow?.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0
            }
            
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        }
        
        let navigationBarHeight = navigationBar.frame.size.height + statusBarHeight
        
        return navigationBarHeight
    }
}
