//
//  Promises+FactoriesTests.swift
//  ProperationsTests
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import XCTest
import Properations


class Promises_FactoriesTests: XCTestCase {

    func testMakeBlocking() throws {
        // func makeBlocking<T>(on queue: OperationQueue, executionQueue: OperationQueue = .main, executionTask: @escaping ((Promise<T>) -> Void) = { _ in }) -> Promise<T> {
        let queue = OperationQueue()
        let future: Future<Bool> = Promise<Bool>.makeBlocking(on: queue, executionQueue: .main) { promise in
            XCTAssertEqual(OperationQueue.current, .main)
            promise.fulfill(with: .success(true))
        }

        try wait(forCompletionOf: future)

        XCTAssertEqual(future.result?.successValue, true)
    }

    func testMakeAwaitingCompletionOf() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(true))
        let future = Promise<Bool>.make(awaitingCompletionOf: initial) { initial -> Bool in
            XCTAssertEqual(OperationQueue.current, .main)
            guard let value = initial.result?.successValue else {
                throw TestError.error
            }
            return value
        }

        try wait(forCompletionOf: future)

        XCTAssertEqual(future.result?.successValue, true)
    }
}
