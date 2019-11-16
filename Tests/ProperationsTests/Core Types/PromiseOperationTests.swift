//
//  PromiseOperationTests.swift
//  ProperationsTests
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import XCTest
import Properations


// Note that we don't test promises that have not been equeued because that is considered incorrect usages.

class PromiseOperationTests: XCTestCase {

    func testResultWithFulfill() throws {
        let promise = Promises.make(promising: Bool.self)

        XCTAssertEqual(promise.isReady, false)
        XCTAssertEqual(promise.isCancelled, false)
        XCTAssertEqual(promise.isExecuting, false)
        XCTAssertEqual(promise.isFinished, false)
        XCTAssertNil(promise.result)

        promise.fulfill(with: .success(true))
        try wait(forCompletionOf: promise)

        XCTAssertEqual(promise.isReady, true)
        XCTAssertEqual(promise.isCancelled, false)
        XCTAssertEqual(promise.isExecuting, false)
        XCTAssertEqual(promise.isFinished, true)
        XCTAssertNotNil(promise.result?.successValue)
    }

    func testResultWithSucceed() throws {
        let promise = Promises.make(promising: Bool.self)

        XCTAssertEqual(promise.isReady, false)
        XCTAssertEqual(promise.isCancelled, false)
        XCTAssertEqual(promise.isExecuting, false)
        XCTAssertEqual(promise.isFinished, false)
        XCTAssertNil(promise.result)

        promise.succeed(with: true)
        try wait(forCompletionOf: promise)

        XCTAssertEqual(promise.isReady, true)
        XCTAssertEqual(promise.isCancelled, false)
        XCTAssertEqual(promise.isExecuting, false)
        XCTAssertEqual(promise.isFinished, true)
        XCTAssertNotNil(promise.result?.successValue)
    }

    func testResultWithFailure() throws {
        let promise = Promises.make(promising: Bool.self)

        XCTAssertEqual(promise.isReady, false)
        XCTAssertEqual(promise.isCancelled, false)
        XCTAssertEqual(promise.isExecuting, false)
        XCTAssertEqual(promise.isFinished, false)
        XCTAssertNil(promise.result)

        promise.fail(with: TestError.error)
        try wait(forCompletionOf: promise)

        XCTAssertEqual(promise.isReady, true)
        XCTAssertEqual(promise.isCancelled, false)
        XCTAssertEqual(promise.isExecuting, false)
        XCTAssertEqual(promise.isFinished, true)
        XCTAssertNotNil(promise.result?.failureValue)
    }

    func testResultWithCancel() throws {
        let promise = Promises.make(promising: Bool.self)

        XCTAssertEqual(promise.isReady, false)
        XCTAssertEqual(promise.isCancelled, false)
        XCTAssertEqual(promise.isExecuting, false)
        XCTAssertEqual(promise.isFinished, false)
        XCTAssertNil(promise.result)

        promise.cancel()
        try wait(forCompletionOf: promise)
        
        XCTAssertEqual(promise.isReady, true)
        XCTAssertEqual(promise.isCancelled, true)
        XCTAssertEqual(promise.isExecuting, false)
        // This is strange. The documentation says that if an operation is cancelled then isFinished should be true.
        // This is correct only if the operation is in a queue.
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

    func testMultipleFulfills() {
        // This is consider a failure because the creator of the promise is responsible for fulfilling it.
        // If the promise is fulfills multiple times that means the creator has not managed the promise correctly.
        return // This test is disabled because it triggers an assertFailure
//        let promise = Promises.make(promising: Bool.self)
//
//        promise.fulfill(with: .success(true))
//        promise.fulfill(with: .success(false))
//        let expectation = self.expectation(description: "")
//        OperationQueue.main.addCompletionOperation(to: promise) { _ in
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 1)
//
//        XCTAssertEqual(promise.result?.successValue, true)
    }

    func testCancelThenFulfill() throws {
        // cancel() is part of the public interface of FutureOperation and so any object, not just the creator, can
        // call cancel(). Therefore the promise may have been cancelled by an object other than its creator.
        let promise = Promises.make(promising: Bool.self)

        promise.cancel()
        promise.fulfill(with: .success(true))
        try wait(forCompletionOf: promise)

        XCTAssert(promise.isCancelled)
    }

    func testFulfillThenCancel() throws {
        // cancel() is part of the public interface of FutureOperation and so any object, not just the creator, can
        // call cancel(). Therefore the promise may have been cancelled by an object other than its creator.
        let promise = Promises.make(promising: Bool.self)

        promise.fulfill(with: .success(true))
        promise.cancel()
        try wait(forCompletionOf: promise)

        XCTAssertEqual(promise.result?.successValue, true)
    }

    func testMultipleCancels() throws {
        // cancel() is part of the public interface of FutureOperation and so any object, not just the creator, can
        // call cancel(). Therefore the promise may have been cancelled by an object other than its creator.
        //        return; // This test is disabled because it triggers an assertFailure
        let promise = Promises.make(promising: Bool.self)

        promise.cancel()
        promise.cancel()
        try wait(forCompletionOf: promise)

        XCTAssert(promise.isCancelled)
    }
}
