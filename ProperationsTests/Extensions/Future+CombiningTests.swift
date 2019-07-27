//
//  Future+CombiningTests.swift
//  ProperationsTests
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import XCTest
import Properations


class Future_CombiningTests: XCTestCase {

    func testCollectWithAllSuccess() throws {
        let results = [FutureResult.success(true), FutureResult.success(false)]
        let futures = results.map { makeAsynchronouslyFulfilledFuture(with: $0) }
        let expected = FutureResult.success([true, false])

        var future: Future<[Bool]>? = Promises.collect(futures)
        weak var weakFuture = future
        try wait(forCompletionOf: future)
        let actual = future?.result
        future = nil

        XCTAssertEqual(equatableDescription(of: expected), equatableDescription(of: actual))
        XCTAssertNil(weakFuture)
    }

    func testCollectWithAFailure() throws {
        let results = [FutureResult.success(true), FutureResult<Bool>.failure(TestError.error)]
        let futures = results.map { makeAsynchronouslyFulfilledFuture(with: $0) }
        let expected = FutureResult<([Bool])>.failure(ProperationsError.multipleErrors([nil, TestError.error]))

        var future: Future<[Bool]>? = Promises.collect(futures)
        weak var weakFuture = future
        try wait(forCompletionOf: future)
        let actual = future?.result
        future = nil

        XCTAssertEqual(equatableDescription(of: expected), equatableDescription(of: actual))
        XCTAssertNil(weakFuture)
    }

    func testCombine2WithAllSuccess() throws {
        typealias Value = (Bool, Bool)
        let future1 = makeAsynchronouslyFulfilledFuture(with: .success(true))
        let future2 = makeAsynchronouslyFulfilledFuture(with: .success(true))
        let expected: Value = (true, true)

        var future: Future<Value>? = Promises.combine(future1, future2)
        weak var weakVarFuture = future
        try wait(forCompletionOf: future, timeout: 1)
        let actual = future?.result?.successValue
        future = nil

        XCTAssertEqual(equatableDescription(of: expected), equatableDescription(of: actual))
        XCTAssertNil(weakVarFuture)
    }

    func testCombine2WithAFailure() throws {
        typealias Value = (Bool, Bool)
        let future1 = makeAsynchronouslyFulfilledFuture(with: FutureResult<Bool>.failure(TestError.error))
        let future2 = makeAsynchronouslyFulfilledFuture(with: .success(true))
        let expected = ProperationsError.multipleErrors([TestError.error, nil])

        var future: Future<Value>? = Promises.combine(future1, future2)
        weak var weakVarFuture = future
        try wait(forCompletionOf: future, timeout: 1)
        let actual = future?.result?.failureValue
        future = nil

        XCTAssertEqual(equatableDescription(of: expected), equatableDescription(of: actual))
        XCTAssertNil(weakVarFuture)
    }

    func testCombine3WithAllSuccess() throws {
        typealias Value = (Bool, Bool, Bool)
        let future1 = makeAsynchronouslyFulfilledFuture(with: .success(true))
        let future2 = makeAsynchronouslyFulfilledFuture(with: .success(true))
        let future3 = makeAsynchronouslyFulfilledFuture(with: .success(true))
        let expected: Value = (true, true, true)

        var future: Future<Value>? = Promises.combine(future1, future2, future3)
        weak var weakVarFuture = future
        try wait(forCompletionOf: future, timeout: 1)
        let actual = future?.result?.successValue
        future = nil

        XCTAssertEqual(equatableDescription(of: expected), equatableDescription(of: actual))
        XCTAssertNil(weakVarFuture)
    }

    func testCombine3WithAFailure() throws {
        typealias Value = (Bool, Bool, Bool)
        let future1 = makeAsynchronouslyFulfilledFuture(with: FutureResult<Bool>.failure(TestError.error))
        let future2 = makeAsynchronouslyFulfilledFuture(with: .success(true))
        let future3 = makeAsynchronouslyFulfilledFuture(with: FutureResult<Bool>.failure(TestError.error))
        let expected = ProperationsError.multipleErrors([TestError.error, nil, TestError.error])

        var future: Future<Value>? = Promises.combine(future1, future2, future3)
        weak var weakVarFuture = future
        try wait(forCompletionOf: future, timeout: 1)
        let actual = future?.result?.failureValue
        future = nil

        XCTAssertEqual(equatableDescription(of: expected), equatableDescription(of: actual))
        XCTAssertNil(weakVarFuture)
    }

    func testCombine4WithAllSuccess() throws {
        typealias Value = (Bool, Bool, Bool, Bool)
        let future1 = makeAsynchronouslyFulfilledFuture(with: .success(true))
        let future2 = makeAsynchronouslyFulfilledFuture(with: .success(true))
        let future3 = makeAsynchronouslyFulfilledFuture(with: .success(true))
        let future4 = makeAsynchronouslyFulfilledFuture(with: .success(true))
        let expected: Value = (true, true, true, true)

        var future: Future<Value>? = Promises.combine(future1, future2, future3, future4)
        weak var weakVarFuture = future
        try wait(forCompletionOf: future, timeout: 1)
        let actual = future?.result?.successValue
        future = nil

        XCTAssertEqual(equatableDescription(of: expected), equatableDescription(of: actual))
        XCTAssertNil(weakVarFuture)
    }

    func testCombine4WithAFailure() throws {
        typealias Value = (Bool, Bool, Bool, Bool)
        let future1 = makeAsynchronouslyFulfilledFuture(with: FutureResult<Bool>.failure(TestError.error))
        let future2 = makeAsynchronouslyFulfilledFuture(with: .success(true))
        let future3 = makeAsynchronouslyFulfilledFuture(with: FutureResult<Bool>.failure(TestError.error))
        let future4 = makeAsynchronouslyFulfilledFuture(with: .success(true))
        let expected = ProperationsError.multipleErrors([TestError.error, nil, TestError.error, nil])

        var future: Future<Value>? = Promises.combine(future1, future2, future3, future4)
        weak var weakVarFuture = future
        try wait(forCompletionOf: future, timeout: 1)
        let actual = future?.result?.failureValue
        future = nil

        XCTAssertEqual(equatableDescription(of: expected), equatableDescription(of: actual))
        XCTAssertNil(weakVarFuture)
    }    
}
