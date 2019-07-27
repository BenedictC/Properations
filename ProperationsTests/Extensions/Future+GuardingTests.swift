//
//  Future+GuardingTests.swift
//  ProperationsTests
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import XCTest
import Properations


class Future_GuardingTests: XCTestCase {

    func testEnsureWithMetCondition() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(true))
        let ensure = initial.ensure { $0 == true }

        try wait(forCompletionOf: ensure)

        XCTAssertEqual(initial.result?.successValue, true)
        XCTAssertEqual(ensure.result?.successValue, true)
    }

    func testEnsureWithUnmetCondition() throws {
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(true))
        let ensure = initial.ensure { $0 == false }

        try wait(forCompletionOf: ensure)

        XCTAssertEqual(initial.result?.successValue, true)
        XCTAssertEqual(equatableDescription(of: ensure.result?.failureValue), equatableDescription(of: ProperationsError.ensureFailed))
    }
}
