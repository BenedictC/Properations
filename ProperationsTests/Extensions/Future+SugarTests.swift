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

    // TODO: We should test the sugar seeing as it's just syntax it's low priority.

    func testSyntax() { // Not really a test
        let initial = Promises.make(promising: Bool.self)
        _ = Promises.make(awaitingCompletionOf: initial) { initial in
            throw TestError.error
        }
    }
}
