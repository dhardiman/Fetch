//
//  SessionActivityMonitorTests.swift
//  FetchTests
//
//  Created by David Hardiman on 17/11/2017.
//  Copyright © 2017 David Hardiman. All rights reserved.
//

@testable import Fetch
import Nimble
import XCTest

class SessionActivityMonitorTests: XCTestCase {
    func testIncrementingTheCountCallsTheHandler() {
        var valueReceived: Bool?
        let exp = expectation(description: "Waiting")
        SessionActivityMonitor.sessionActivityChanged = { isActive in
            valueReceived = isActive
            exp.fulfill()
        }
        let monitor = SessionActivityMonitor()
        monitor.incrementCount()
        waitForExpectations(timeout: 1.0, handler: nil)
        expect(valueReceived).to(beTrue())
    }

    func testDecrementingTheCountCallsTheHandler() {
        var valueReceived: Bool = true
        let monitor = SessionActivityMonitor(initialValue: 1)

        let exp = expectation(description: "Waiting")
        SessionActivityMonitor.sessionActivityChanged = { isActive in
            valueReceived = isActive
            exp.fulfill()
        }
        monitor.decrementCount()

        waitForExpectations(timeout: 1.0, handler: nil)
        expect(valueReceived).to(beFalse())
    }

    func testWhenIncrementingItOnlyNotifiesIfTheValueChanges() {
        var callCount = 0
        SessionActivityMonitor.sessionActivityChanged = { _ in
            callCount += 1
        }
        let monitor = SessionActivityMonitor(isAsynchronous: false)
        monitor.incrementCount()
        monitor.incrementCount()
        expect(callCount).to(equal(1))
    }

    func testWhenDecrementingItOnlyNotifiesIfTheValueChanges() {
        let monitor = SessionActivityMonitor(initialValue: 2, isAsynchronous: false)
        var callCount = 0
        SessionActivityMonitor.sessionActivityChanged = { _ in
            callCount += 1
        }
        monitor.decrementCount()
        monitor.decrementCount()
        monitor.decrementCount()
        expect(callCount).to(equal(1))
    }
}
