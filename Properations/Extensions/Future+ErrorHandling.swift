//
//  Future+ErrorHandling.swift
//  Properations
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


// MARK: - Error handling

extension FutureResultable where Self: Operation {

    /// The returned future is fulfilled after the handler is executed.
    public func recover(on executionQueue: OperationQueue = .main, errorHandler: @escaping (Error) throws -> Success) -> Future<Success> {
        // Create and enqueue a promise which will be used as the return value.
        let promise = Promise<Success>.make()
        // When progress completes...
        executionQueue.addCompletionOperation(to: self) { future in
            if promise.isCancelled {
                return
            }
            switch future.fulfilledResult {
            case .failure(let error):
                // self failed so extract the error, pass it to the supplied handler and use the returned/thrown result to fulfill the promise.
                do {
                    let newValue = try errorHandler(error)
                    promise.succeed(with: newValue)
                } catch {
                    promise.fail(with: error)
                }

            case .success( let value):
                // self was successful so we have no need for error handling.
                promise.succeed(with: value)
            }
        }
        return promise
    }
}
