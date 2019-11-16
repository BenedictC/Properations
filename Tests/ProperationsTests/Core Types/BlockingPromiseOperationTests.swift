//
//  BlockingPromiseOperationTests.swift
//  ProperationsTests
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import XCTest
import Properations


class BlockingPromiseOperationTests: XCTestCase {

    func testResultWithFulfill() throws {
        let queue = OperationQueue()
        let executionBegan = expectation(description: "Execution began")
        let promise = Promises.makeBlocking(on: queue, promising: Bool.self) { promise in
            executionBegan.fulfill()
        }
        wait(for: [executionBegan], timeout: 1)

        XCTAssertEqual(promise.isReady, true)
        XCTAssertEqual(promise.isCancelled, false)
        XCTAssertEqual(promise.isExecuting, true)
        XCTAssertEqual(promise.isFinished, false)
        XCTAssertNil(promise.result)

        promise.fulfill(with: .success(true))
        try wait(forCompletionOf: promise, timeout: 1)

        XCTAssertEqual(promise.isReady, true)
        XCTAssertEqual(promise.isCancelled, false)
        XCTAssertEqual(promise.isExecuting, false)
        XCTAssertEqual(promise.isFinished, true)
        XCTAssertNotNil(promise.result?.successValue)
    }

    func testResultWithCancel() throws {
        let queue = OperationQueue()
        let executionBegan = expectation(description: "Execution began")
        let promise = Promises.makeBlocking(on: queue, promising: Bool.self) { promise in
            executionBegan.fulfill()
        }
        wait(for: [executionBegan], timeout: 1)

        XCTAssertEqual(promise.isReady, true)
        XCTAssertEqual(promise.isCancelled, false)
        XCTAssertEqual(promise.isExecuting, true)
        XCTAssertEqual(promise.isFinished, false)
        XCTAssertNil(promise.result)

        promise.cancel()
        try wait(forCompletionOf: promise, timeout: 1)

        XCTAssertEqual(promise.isReady, true)
        XCTAssertEqual(promise.isCancelled, true)
        XCTAssertEqual(promise.isExecuting, false)
        XCTAssertEqual(promise.isFinished, true)
        do {
            _ = try promise.result?.get()
            XCTFail()
        } catch ProperationsError.cancelled {
            XCTAssert(true)
        } catch {
            XCTAssert(true)
        }
    }
}
