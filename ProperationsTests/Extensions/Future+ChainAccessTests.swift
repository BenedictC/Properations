//
//  Future+ChainAccessTests.swift
//  ProperationsTests
//
//  Created by Benedict Cohen on 28/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import XCTest
import Properations


class Future_ChainAccessTests: XCTestCase {

    func testGetFuture() {
        var future: Future<Bool>?
        let initial = makeAsynchronouslyFulfilledFuture(with: .success(true))
            .getFuture { future = $0 }

        XCTAssertEqual(future, initial)
    }
}
