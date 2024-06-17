//
//  AndroidTimer.swift
//  Demo
//
//  Created by 赵江明 on 2024/6/17.
//  Copyright © 2024 赵江明. All rights reserved.
//

import UIKit

class AndroidTimerTarget {
    var target: AnyObject?
    var selector: Selector?
    var timer: Timer?

    init() {}

    @objc func fire(timer: Timer) {
        if let target = target, let selector = selector {
            _ = target.perform(selector, with: timer.userInfo, afterDelay: 0.0)
        } else {
            self.timer?.invalidate()
        }
    }
}

class AndroidTimer {
    static func scheduledTimer(withTimeInterval interval: TimeInterval,
                               target: AnyObject,
                               selector: Selector,
                               userInfo: Any?,
                               repeats: Bool) -> Timer
    {
        let timerTarget = AndroidTimerTarget()
        timerTarget.target = target
        timerTarget.selector = selector
        timerTarget.timer = Timer.scheduledTimer(timeInterval: interval,
                                                 target: timerTarget,
                                                 selector: #selector(AndroidTimerTarget.fire(timer:)),
                                                 userInfo: userInfo,
                                                 repeats: repeats)
        return timerTarget.timer!
    }
}

