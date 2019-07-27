//
//  TestError.swift
//  ProperationsTests
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation
import XCTest
@testable import Properations


// MARK: - TestError

enum TestError: Error, Equatable {
    case error
}


// MARK: - Equatable helpers

func equatableDescription<T>(of optionalValue: Optional<T>) -> String {
    return optionalValue.flatMap({ equatableDescription(of: $0) }) ?? ""
}

func equatableDescription<T>(of value: T) -> String {
    return "\(value)"
}


// MARK: - Operation helpers

extension XCTestCase {

    func makeAsynchronouslyFulfilledFuture<T>(with result: FutureResult<T>, delay: DispatchTimeInterval = .milliseconds(10)) -> Future<T> {
        let promise = Promises.make(promising: T.self)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            promise.fulfill(with: result)
        }
        return promise
    }

    func wait(forCompletionOf operations: Operation?..., timeout: TimeInterval = 1) throws {
        // Create a completion and expectation for each operation
        let exceptations = operations
            .compactMap { $0 }
            .map { operation -> XCTestExpectation in
                let completionException = self.expectation(description: "")
                OperationQueue.main.addCompletionOperation(to: operation) { operation in
                    completionException.fulfill()
                }
                return completionException
        }
        if exceptations.isEmpty {
            return
        }

        // Wait for all expectation to be fulfilled
        var error: Error?
        waitForExpectations(timeout: timeout) { error = $0 }
        if let error = error {
            throw error
        }
    }
}
