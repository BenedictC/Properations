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
        let initial = makeAsynchronouslyFulfilledFuture(with: .success([1, nil, 2]))
        let expected = ["1", "2"]

        let future = initial.compactMapElementsToValue { $0.map { "\($0)" } }
        try wait(forCompletionOf: future)

        let actual = future.result?.successValue
        XCTAssertEqual(actual, expected)
    }

    func testCompactMapElementsToValueWithAFailure() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success([1, nil, 2]))
        let expected = TestError.error

        let future = initial.compactMapElementsToValue { int -> String? in
            guard let int = int else { return nil }
            guard int == 1 else { throw TestError.error }
            return "\(int)"
        }
        try wait(forCompletionOf: future)

        let actual = future.result?.failureValue
        XCTAssertEqual(equatableDescription(of: actual), equatableDescription(of: expected))
    }


    // MARK: compactMapElementsToFuture

    func testCompactMapElementsToFutureWithSuccess() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success([1, nil, 2]))
        let expected = ["1", "2"]

        let future = initial.compactMapElementsToFuture { int -> Future<String>? in
            guard let int = int else { return nil }
            return Promises.makeFulfilled(with: .success("\(int)"))
        }
        try wait(forCompletionOf: future)

        let actual = future.result?.successValue
        XCTAssertEqual(actual, expected)
    }

    func testCompactMapElementsToFutureWithAMapFailure() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success([1, nil, 2]))
        let expected = TestError.error

        let future = initial.compactMapElementsToFuture { int -> Future<String>? in
            guard let int = int else { return nil }
            guard int == 1 else { throw TestError.error }
            return Promises.makeFulfilled(with: .success("\(int)"))
        }
        try wait(forCompletionOf: future)

        let actual = future.result?.failureValue
        XCTAssertEqual(equatableDescription(of: actual), equatableDescription(of: expected))
    }

    func testCompactMapElementsToFutureWithAFutureFailure() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success([1, nil, 2]))
        let expected = ProperationsError.multipleErrors([nil, TestError.error])

        let future = initial.compactMapElementsToFuture { int -> Future<String>? in
            guard let int = int else { return nil }
            if int == 1 {
                return Promises.makeFulfilled(with: .success("\(int)"))
            }
            return Promises.makeFulfilled(with: .failure(TestError.error))
        }
        try wait(forCompletionOf: future)

        let actual = future.result?.failureValue
        XCTAssertEqual(equatableDescription(of: actual), equatableDescription(of: expected))
    }

    // MARK: mapElementsToValue

    func testMapElementsToValueWithSuccess() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success([1, nil, 2]))
        let expected = ["1", "", "2"]

        let future = initial.mapElementsToFuture { int -> Future<String> in
            guard let int = int else { return Promises.makeFulfilled(with: .success("")) }
            return Promises.makeFulfilled(with: .success("\(int)"))
        }
        try wait(forCompletionOf: future)

        let actual = future.result?.successValue
        XCTAssertEqual(actual, expected)
    }


    func testMapElementsToValueWithAFailure() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success([1, nil, 2]))
        let expected = TestError.error

        let future = initial.mapElementsToValue { int -> String in
            guard let int = int else { return "" }
            guard int == 1 else { throw TestError.error }
            return "\(int)"
        }
        try wait(forCompletionOf: future)

        let actual = future.result?.failureValue
        XCTAssertEqual(equatableDescription(of: actual), equatableDescription(of: expected))
    }

    // MARK: mapElementsToFuture

    func testMapElementsToFutureWithSuccess() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success([1, nil, 2]))
        let expected = ["1", "", "2"]

        let future = initial.mapElementsToFuture { int -> Future<String> in
            guard let int = int else { return Promises.makeFulfilled(with: .success("")) }
            return Promises.makeFulfilled(with: .success("\(int)"))
        }
        try wait(forCompletionOf: future)

        let actual = future.result?.successValue
        XCTAssertEqual(actual, expected)
    }

    func testMapElementsToFutureWithAMapFailure() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success([1, nil, 2]))
        let expected = TestError.error

        let future = initial.mapElementsToFuture { int -> Future<String> in
            guard let int = int else { return Promises.makeFulfilled(with: .success("")) }
            guard int == 1 else { throw TestError.error }
            return Promises.makeFulfilled(with: .success("\(int)"))
        }
        try wait(forCompletionOf: future)

        let actual = future.result?.failureValue
        XCTAssertEqual(equatableDescription(of: actual), equatableDescription(of: expected))
    }

    func testMapElementsToFutureWithAFutureFailure() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success([1, nil, 2]))
        let expected = ProperationsError.multipleErrors([nil, nil, TestError.error])

        let future = initial.mapElementsToFuture { int -> Future<String> in
            guard let int = int else { return Promises.makeFulfilled(with: .success("")) }
            if int == 1 {
                return Promises.makeFulfilled(with: .success("\(int)"))
            }
            return Promises.makeFulfilled(with: .failure(TestError.error))
        }
        try wait(forCompletionOf: future)

        let actual = future.result?.failureValue
        XCTAssertEqual(equatableDescription(of: actual), equatableDescription(of: expected))
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
