//
//  Future+InterdependenciesTests.swift
//  ProperationsTests
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import XCTest
import Properations


class Future_InterdependenciesTests: XCTestCase {

    func testCancelOnFailureWithSuccess() throws {
        let initial1 = makeAsynchronouslyFulfilledFuture(with: .success(true), delay: .nanoseconds(0))
        let initial2 = makeAsynchronouslyFulfilledFuture(with: .success(true), delay: .milliseconds(10))
        initial2.cancel(onFailureOf: initial1)

        try wait(forCompletionOf: initial1, initial2)

        XCTAssertEqual(initial1.result?.isSuccess, true)
        XCTAssertEqual(initial2.result?.isSuccess, true)
    }

    func testCancelOnFailureWithFailure() throws {
        let initial1 = makeAsynchronouslyFulfilledFuture(with: FutureResult<Bool>.failure(TestError.error), delay: .nanoseconds(0))
        let initial2 = makeAsynchronouslyFulfilledFuture(with: .success(true), delay: .milliseconds(10))
        initial2.cancel(onFailureOf: initial1)

        try wait(forCompletionOf: initial1, initial2)

        XCTAssertEqual(initial1.result?.isFailure, true)
        XCTAssertEqual(initial2.isCancelled, true)
    }

    func testRaceWithASuccess() throws {
        let futures = [
            makeAsynchronouslyFulfilledFuture(with: FutureResult.success(true), delay: .milliseconds(10)),
            makeAsynchronouslyFulfilledFuture(with: FutureResult.success(false), delay: .milliseconds(20)),
        ]

        let future = Promises.race(futures)
        try wait(forCompletionOf: future)

        // TODO: test that we completed faster than the slowest input
        XCTAssertEqual(future.result?.successValue, true)
    }

    func testRaceWithFailure() throws {
        let futures = [
            makeAsynchronouslyFulfilledFuture(with: FutureResult<Bool>.failure(TestError.error), delay: .milliseconds(10)),
            makeAsynchronouslyFulfilledFuture(with: FutureResult<Bool>.failure(TestError.error), delay: .milliseconds(20)),
        ]

        let future = Promises.race(futures)
        try wait(forCompletionOf: future)

        let expected = ProperationsError.multipleErrors([
            TestError.error,
            TestError.error,
            ])
        let actual = future.result?.failureValue
        XCTAssertEqual(equatableDescription(of: actual), equatableDescription(of: expected))
    }
}
