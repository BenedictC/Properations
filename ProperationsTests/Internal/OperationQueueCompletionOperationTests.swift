//
//  OperationQueueCompletionOperationTests.swift
//  ProperationsTests
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import XCTest
@testable import Properations


class OperationQueueCompletionOperationTests: XCTestCase {

    func testCompletionOperationIsAddedToQueue() {
        let initialOperation = BlockOperation()
        let queue = OperationQueue()

        let completionOperation = queue.addCompletionOperation(to: initialOperation, completionHandler: { _ in })

        XCTAssert(queue.operations.contains(completionOperation))
    }

    func testCompletionOperationIsDependantOnInitialOperation() {
        let initialOperation = BlockOperation()
        let queue = OperationQueue()

        let completionOperation = queue.addCompletionOperation(to: initialOperation, completionHandler: { _ in })

        XCTAssert(completionOperation.dependencies.contains(initialOperation))
    }

    func testCompletionOperationHandlerUsesCorrectOperation() {
        let initialOperation = BlockOperation()
        let queue = OperationQueue()

        let expectation = self.expectation(description: "completion handler")
        var actualOperation: Operation?
        queue.addCompletionOperation(to: initialOperation, completionHandler: { operation in
            actualOperation = operation
            expectation.fulfill()
        })
        queue.addOperation(initialOperation)
        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(actualOperation, initialOperation)
    }

    func testRetainCycleIsBroken() {
        // If the completion operation captures the initial op then it will create a retain cycle.
        var initialOperation: BlockOperation? = BlockOperation()
        weak var weakInitialOp = initialOperation
        let queue = OperationQueue()

        let expectation = self.expectation(description: "completion handler")
        queue.addCompletionOperation(to: initialOperation!, completionHandler: { operation in
            expectation.fulfill()
        })
        queue.addOperation(initialOperation!)
        initialOperation = nil
        wait(for: [expectation], timeout: 1)

        XCTAssertNil(weakInitialOp)
    }

    func testCompletionFiresWhenInitialIsAlreadyFinished() {
        // Given a complete operation
        let initalOpCompletedExceptation = expectation(description: "")
        let initialOperation = BlockOperation()
        initialOperation.completionBlock = {
            initalOpCompletedExceptation.fulfill()
        }
        let queue = OperationQueue()
        queue.addOperation(initialOperation)
        wait(for: [initalOpCompletedExceptation], timeout: 1)

        // When we add completion operation
        let completionOpCompletedExpectation = self.expectation(description: "completion handler")
        let completionOperation = queue.addCompletionOperation(to: initialOperation, completionHandler: { operation in
            completionOpCompletedExpectation.fulfill()
        })
        wait(for: [completionOpCompletedExpectation], timeout: 1)

        // Then the completion should fire
        XCTAssert(completionOperation.isFinished)
    }
}
