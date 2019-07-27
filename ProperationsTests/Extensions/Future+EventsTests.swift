//
//  Future+EventsTests.swift
//  ProperationsTests
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import XCTest
import Properations


class Future_EventsTests: XCTestCase {

    var future: Future<Bool>?

    override func tearDown() {
        future = nil
    }


    func testOnCompletion() {
        let expected = FutureResult.success(true)
        let initial = makeAsynchronouslyFulfilledFuture(with: expected)
        var paramActual: FutureResult<Bool>? // Ensure that method provides the result
        var ivarActual: FutureResult<Bool>? // Ensures that the method fulfills the promise before invoking the handler

        let expectation = self.expectation(description: "")
        self.future = initial.onCompletion { result in
            ivarActual = self.future?.result
            paramActual = result
            expectation.fulfill()
        }
        weak var weakFuture = self.future
        wait(for: [expectation], timeout: 1)
        self.future = nil

        XCTAssertEqual(expected.successValue, paramActual?.successValue)
        XCTAssertEqual(expected.successValue, ivarActual?.successValue)
        XCTAssertNil(weakFuture)
    }

    func testOnSuccess() {
        let expected = FutureResult.success(true)
        let initial = makeAsynchronouslyFulfilledFuture(with: expected)
        var paramActual: Bool? // Ensure that method provides the result
        var ivarActual: Bool? // Ensures that the method fulfills the promise before invoking the handler

        let expectation = self.expectation(description: "")
        self.future = initial.onSuccess { result in
            ivarActual = self.future?.result?.successValue
            paramActual = result
            expectation.fulfill()
        }
        weak var weakFuture = self.future
        wait(for: [expectation], timeout: 1)
        self.future = nil

        XCTAssertEqual(expected.successValue, paramActual)
        XCTAssertEqual(expected.successValue, ivarActual)
        XCTAssertNil(weakFuture)
    }

    func testOnFailure() {
        let expected = FutureResult<Bool>.failure(TestError.error)
        let initial = makeAsynchronouslyFulfilledFuture(with: expected)
        var paramActual: Error? // Ensure that method provides the result
        var ivarActual: Error? // Ensures that the method fulfills the promise before invoking the handler

        let expectation = self.expectation(description: "")
        self.future = initial.onFailure { result in
            ivarActual = self.future?.result?.failureValue
            paramActual = result
            expectation.fulfill()
        }
        weak var weakFuture = self.future
        wait(for: [expectation], timeout: 1)
        self.future = nil

        XCTAssertEqual(equatableDescription(of: expected.failureValue), equatableDescription(of: paramActual))
        XCTAssertEqual(equatableDescription(of: expected.failureValue), equatableDescription(of: ivarActual))
        XCTAssertNil(weakFuture)
    }

    func testOnCancelation() {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(true))

        initial.cancel()
        var cancellationResult: Error? = nil
        let expectation = self.expectation(description: "cancelled")
        self.future = initial.onCancel {
            cancellationResult = self.future?.result?.failureValue
            expectation.fulfill()
        }
        weak var weakFuture = self.future
        wait(for: [expectation], timeout: 1)
        self.future = nil

        XCTAssertEqual(equatableDescription(of: cancellationResult), equatableDescription(of: ProperationsError.cancelled))
        XCTAssertNil(weakFuture)
    }
}
