//
//  SessionActivityMonitor.swift
//  Fetch
//
//  Created by David Hardiman on 17/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

import Foundation

/// Counts number of requests initiated through the `Session` class
public final class SessionActivityMonitor {

    /// Handler type. Bool param is `true` when there are active tasks
    public typealias SessionActivityHandler = (Bool) -> Void

    /// Closure to call when the activity changes
    public static var sessionActivityChanged: SessionActivityHandler?

    private var isAsynchronous: Bool

    static let shared = SessionActivityMonitor()

    init(initialValue: Int = 0, isAsynchronous: Bool = true) {
        self.taskCount = initialValue
        self.isAsynchronous = isAsynchronous
    }

    private func dispatch(_ action: @escaping () -> Void) {
        if isAsynchronous {
            DispatchQueue.main.async { action() }
        } else {
            action()
        }
    }

    private var taskCount: Int {
        didSet {
            let oldActivityValue = oldValue > 0
            let newActivityValue = taskCount > 0
            if oldActivityValue != newActivityValue {
                dispatch {
                    SessionActivityMonitor.sessionActivityChanged?(newActivityValue)
                }
            }
        }
    }

    private let activityQueue = DispatchQueue(label: "me.davidhardiman.SessionActivityMonitor")

    func incrementCount() {
        activityQueue.sync {
            self.taskCount += 1
        }
    }

    func decrementCount() {
        activityQueue.sync {
            self.taskCount -= 1
        }
    }
}
