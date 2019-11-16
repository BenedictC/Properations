//
//  Future+TimingTests.swift
//  ProperationsTests
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import XCTest
import Properations


class Future_TimingTests: XCTestCase {

    func testDelaySuccess() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(true), delay: .seconds(0))
        try wait(forCompletionOf: initial)

        let start = DispatchTime.now()
        let intervalInNanoseconds = 1_000_000_000 // 1 second
        let delay = initial.delay(for: .nanoseconds(intervalInNanoseconds))
        try wait(forCompletionOf: delay, timeout: 2)
        let end = DispatchTime.now()

        let expected = intervalInNanoseconds
        let actual = end.uptimeNanoseconds - start.uptimeNanoseconds
        XCTAssert(actual >= expected)
    }

    func testDelayCancelled() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(true), delay: .seconds(0))
        try wait(forCompletionOf: initial)

        let start = DispatchTime.now()
        let intervalInNanoseconds = 1_000_000_000 * 60 // 1 minute
        let delay = initial.delay(for: .nanoseconds(intervalInNanoseconds))
        delay.cancel()
        try wait(forCompletionOf: delay, timeout: 60)
        let end = DispatchTime.now()

        let expected = intervalInNanoseconds
        let actual = end.uptimeNanoseconds - start.uptimeNanoseconds
        XCTAssert(actual < expected)
    }
}
