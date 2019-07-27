//
//  FutureResultTests.swift
//  ProperationsTests
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import XCTest
import Properations


class FutureResultTests: XCTestCase {

    func testIsResultFulfilledWithSuccess() {
        let promise = Promises.make(promising: Void.self)

        XCTAssertEqual(promise.isResultFulfilled, false)
        promise.succeed()
        XCTAssertEqual(promise.isResultFulfilled, true)
    }

    func testIsResultFulfilledWithFailure() {
        let promise = Promises.make(promising: Void.self)

        XCTAssertEqual(promise.isResultFulfilled, false)
        promise.fail(with: TestError.error)
        XCTAssertEqual(promise.isResultFulfilled, true)
    }

    func testResultValuePropertiesWithSuccess() {
        let result = FutureResult<Bool>.success(true)

        XCTAssertEqual(result.isSuccess, true)
        XCTAssertEqual(result.successValue, true)
        XCTAssertEqual(result.isFailure, false)
        XCTAssertNil(result.failureValue)
    }

    func testResultValuePropertiesWithFailure() {
        let result = FutureResult<Bool>.failure(TestError.error)

        XCTAssertEqual(result.isSuccess, false)
        XCTAssertNil(result.successValue)
        XCTAssertEqual(result.isFailure, true)
        XCTAssertNotNil(result.failureValue)
    }
}
