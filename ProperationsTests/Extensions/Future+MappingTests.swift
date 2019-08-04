//
//  Future+MappingTests.swift
//  ProperationsTests
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import XCTest
import Properations


class Future_MappingTests: XCTestCase {

    // MARK: compactMapToValue

    func testCompactMapToValueWithValue() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(2))

        let future = initial.compactMapToValue { $0.isMultiple(of: 2) }
        try wait(forCompletionOf: future)

        XCTAssertEqual(future.result?.successValue, true)
    }

    func testCompactMapToValueWithNil() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(2))

        let future = initial.compactMapToValue { _ -> Bool? in return nil }
        try wait(forCompletionOf: future)

        XCTAssertEqual(equatableDescription(of: future.result?.failureValue), equatableDescription(of: ProperationsError.compactMapReturnedNil))
    }

    func testCompactMapToValueThrows() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(2))

        let future = initial.compactMapToValue { _ -> Bool? in throw TestError.error }
        try wait(forCompletionOf: future)

        XCTAssertEqual(equatableDescription(of: future.result?.failureValue), equatableDescription(of: TestError.error))
    }


    // MARK: mapToValue

    func testMapToValueWithValue() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(2))

        let future = initial.mapToValue { $0.isMultiple(of: 2) }
        try wait(forCompletionOf: future)

        XCTAssertEqual(future.result?.successValue, true)
    }

    func testMapToValueThrows() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(2))

        let future = initial.mapToValue { _ -> Bool in throw TestError.error }
        try wait(forCompletionOf: future)

        XCTAssertEqual(equatableDescription(of: future.result?.failureValue), equatableDescription(of: TestError.error))
    }


    // MARK: compactMapElementsToValue

    func testCompactMapElementsToValueWithSuccess() throws {
        XCTFail()
    }

    func testCompactMapElementsToValueWithAFailure() throws {
        XCTFail()
    }


    // MARK: compactMapElementsToFuture

    func testCompactMapElementsToFutureWithSuccess() throws {
        XCTFail()
    }

    func testCompactMapElementsToFutureAFailure() throws {
        XCTFail()
    }


    // MARK: mapElementsToValue

    func testMapElementsToValueWithSuccess() throws {
        XCTFail()
    }

    func testMapElementsToValueWithAFailure() throws {
        XCTFail()
    }


    // MARK: mapElementsToFuture

    func testElementsToFutureWithSuccess() throws {
        XCTFail()
    }

    func testElementsToFutureWithAFailure() throws {
        XCTFail()
    }
    

    // MARK: mapFuture

    func testMapFutureWithFuture() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(2))
        let expected = FutureResult.success(true)

        let future = initial.mapToFuture { _ in
            return self.makeAsynchronouslyFulfilledFuture(with: expected)
        }
        try wait(forCompletionOf: future)
        let actual = future.result

        XCTAssertEqual(equatableDescription(of: expected), equatableDescription(of: actual))
    }

    func testMapFutureThrows() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(2))
        let expected = FutureResult<Bool>.failure(TestError.error)

        let future = initial.mapToFuture { _ in
            return self.makeAsynchronouslyFulfilledFuture(with: expected)
        }
        try wait(forCompletionOf: future)
        let actual = future.result

        XCTAssertEqual(equatableDescription(of: expected), equatableDescription(of: actual))
    }
}
