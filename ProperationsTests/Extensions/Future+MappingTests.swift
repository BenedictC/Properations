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

    // MARK: compactMapValue

    func testCompactMapValueWithValue() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(2))

        let future = initial.compactMapValue { $0.isMultiple(of: 2) }
        try wait(forCompletionOf: future)

        XCTAssertEqual(future.result?.successValue, true)
    }

    func testCompactMapValueWithNil() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(2))

        let future = initial.compactMapValue { _ -> Bool? in return nil }
        try wait(forCompletionOf: future)

        XCTAssertEqual(equatableDescription(of: future.result?.failureValue), equatableDescription(of: ProperationsError.compactMapReturnedNil))
    }

    func testCompactMapValueThrows() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(2))

        let future = initial.compactMapValue { _ -> Bool? in throw TestError.error }
        try wait(forCompletionOf: future)

        XCTAssertEqual(equatableDescription(of: future.result?.failureValue), equatableDescription(of: TestError.error))
    }


    // MARK: mapValue

    func testMapValueWithValue() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(2))

        let future = initial.mapValue { $0.isMultiple(of: 2) }
        try wait(forCompletionOf: future)

        XCTAssertEqual(future.result?.successValue, true)
    }

    func testMapValueThrows() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(2))

        let future = initial.mapValue { _ -> Bool in throw TestError.error }
        try wait(forCompletionOf: future)

        XCTAssertEqual(equatableDescription(of: future.result?.failureValue), equatableDescription(of: TestError.error))
    }


    // MARK: mapFuture

    func testMapFutureWithFuture() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(2))
        let expected = FutureResult.success(true)

        let future = initial.mapFuture { _ in
            return self.makeAsynchronouslyFulfilledFuture(with: expected)
        }
        try wait(forCompletionOf: future)
        let actual = future.result

        XCTAssertEqual(equatableDescription(of: expected), equatableDescription(of: actual))
    }

    func testMapFutureThrows() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(2))
        let expected = FutureResult<Bool>.failure(TestError.error)

        let future = initial.mapFuture { _ in
            return self.makeAsynchronouslyFulfilledFuture(with: expected)
        }
        try wait(forCompletionOf: future)
        let actual = future.result

        XCTAssertEqual(equatableDescription(of: expected), equatableDescription(of: actual))
    }
}
