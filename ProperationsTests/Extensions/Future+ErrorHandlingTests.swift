//
//  Future+ErrorHandlingTests.swift
//  ProperationsTests
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import XCTest
import Properations


class Future_ErrorHandlingTests: XCTestCase {

    func testRecoverDoesNotFireFromSuccess() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(true))
        var didRecover = false

        var future: Future<Bool>? = initial.recover { error in
            didRecover = true
            throw error
        }
        weak var weakFuture = future
        try wait(forCompletionOf: future, timeout: 1)
        future = nil

        XCTAssertEqual(didRecover, false)
        XCTAssertNil(weakFuture)
    }

    func testRecoverWithThrowsNewError() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(true))
        initial.cancel()
        let expected = TestError.error

        weak var weakFuture: Future<Bool>?
        var future: Future<Bool>? = initial.recover { error in
            // TODO: Should we check that the value of self has been set?
            throw expected
        }
        weakFuture = future

        try wait(forCompletionOf: future, timeout: 1)
        let actual = future?.result?.failureValue
        future = nil

        XCTAssertEqual(equatableDescription(of: expected), equatableDescription(of: actual))
        XCTAssertNil(weakFuture)
    }

    func testRecoverWithReturnValue() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(true))
        let expected = true

        weak var weakFuture: Future<Bool>?
        var future: Future<Bool>? = initial.recover { error in
            // TODO: Should we check that the value of self has been set?
            return expected
        }
        weakFuture = future

        try wait(forCompletionOf: future, timeout: 1)
        let actual = future?.result?.successValue
        future = nil

        XCTAssertEqual(expected, actual)
        XCTAssertNil(weakFuture)
    }
}
