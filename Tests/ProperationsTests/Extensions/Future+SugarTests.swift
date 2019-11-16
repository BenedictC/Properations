//
//  Future+SugarTests.swift
//  ProperationsTests
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import XCTest
import Properations


class Future_SugarTests: XCTestCase {

    // TODO: Figure out why type inference fails for `let f = f1 + f2 + f3` but succeeds for `let f1f2 = f1 + f2; let f = f1f2 + f3`

//    func testCombineLR() throws {
//        let f1 = Promises.makeFulfilled(with: .success(1))
//        let f2 = Promises.makeFulfilled(with: .success(2))
//        let expected = (1, 2)
//
//        let future = f1 + f2
//        try wait(forCompletionOf: future)
//        let actual = future.result?.successValue
//
//        XCTAssertEqual(equatableDescription(of: actual), equatableDescription(of: expected))
//    }
//
//    func testCombineLR1R2() throws {
//        let f1 = Promises.makeFulfilled(with: .success(1))
//        let f2 = Promises.makeFulfilled(with: .success((2, 3)))
//        let expected = (1, 2, 3)
//
//        let future = f1 + f2
//        try wait(forCompletionOf: future)
//        let actual = future.result?.successValue
//
//        XCTAssertEqual(equatableDescription(of: actual), equatableDescription(of: expected))
//    }
//
//    func testCombineLR1R2R3() throws {
//        let f1 = Promises.makeFulfilled(with: .success(1))
//        let f2 = Promises.makeFulfilled(with: .success((2, 3, 4)))
//        let expected = (1, 2, 3, 4)
//
//        let future = f1 + f2
//        try wait(forCompletionOf: future)
//        let actual = future.result?.successValue
//
//        XCTAssertEqual(equatableDescription(of: actual), equatableDescription(of: expected))
//    }
//
//    func testCombineL1L2R() throws {
//        let f1 = Promises.makeFulfilled(with: .success((1, 2)))
//        let f2 = Promises.makeFulfilled(with: .success((3)))
//        let expected = (1, 2, 3)
//
//        let future = f1 + f2
//        try wait(forCompletionOf: future)
//        let actual = future.result?.successValue
//
//        XCTAssertEqual(equatableDescription(of: actual), equatableDescription(of: expected))
//    }
//
//    func testCombineL1L2L3R() throws {
//        let f1 = Promises.makeFulfilled(with: .success((1, 2, 3)))
//        let f2 = Promises.makeFulfilled(with: .success((4)))
//        let expected = (1, 2, 3, 4)
//
//        let future = f1 + f2
//        try wait(forCompletionOf: future)
//        let actual = future.result?.successValue
//
//        XCTAssertEqual(equatableDescription(of: actual), equatableDescription(of: expected))
//    }
//
//    func testCombineL1L2R1R2() throws {
//        let f1 = Promises.makeFulfilled(with: .success((1, 2)))
//        let f2 = Promises.makeFulfilled(with: .success((3, 4)))
//        let expected = (1, 2, 3, 4)
//
//        let future = f1 + f2
//        try wait(forCompletionOf: future)
//        let actual = future.result?.successValue
//
//        XCTAssertEqual(equatableDescription(of: actual), equatableDescription(of: expected))
//    }
//
//    func testCombine3Futures() throws {
//        let f1 = Promises.makeFulfilled(with: .success((1)))
//        let f2 = Promises.makeFulfilled(with: .success((2)))
//        let f3 = Promises.makeFulfilled(with: .success((3)))
//        let expected = (1, 2, 3)
//
//        let f1f2 = f1 || f2; let future = f1f2 + f3
//        let future = f1 + f2 + f3
//        try wait(forCompletionOf: future)
//        let actual = future.result?.successValue
//
//        XCTAssertEqual(equatableDescription(of: actual), equatableDescription(of: expected))
//    }
}
