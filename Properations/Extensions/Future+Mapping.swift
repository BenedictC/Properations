//
//  Future+Mapping.swift
//  Properations
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


// MARK: - Value mapping

public extension FutureResultable where Self: Operation {

    func compactMapValue<U>(on executionQueue: OperationQueue = .main, using mapper: @escaping (Success) throws -> U?) -> Future<U> {
        // Create and enqueue a promise which will be used as the return value.
        let promise = Promise<U>.make()
        // When self completes...
        executionQueue.addCompletionOperation(to: self) { future in
            if promise.isCancelled {
                return
            }
            switch future.fulfilledResult {
            case .failure(let error):
                // If self failed then skip this step and fulfill the promise by passing along the error.
                promise.fail(with: error)

            case .success(let value):
                // Execute the task. The task will generally complete asynchronously but it can complete synchronously too (not that it makes any difference to the promise operation).
                do {
                    guard let nextValue = try mapper(value) else {
                        throw ProperationsError.compactMapReturnedNil
                    }
                    promise.succeed(with: nextValue)
                } catch {
                    promise.fail(with: error)
                }
            }
        }

        return promise
    }

    func mapValue<U>(on executionQueue: OperationQueue = .main, using mapper: @escaping (Success) throws -> U) -> Future<U> {
        // Create and enqueue a promise which will be used as the return value.
        let promise = Promise<U>.make()
        // When self completes...
        executionQueue.addCompletionOperation(to: self) { future in
            if promise.isCancelled {
                return
            }
            switch future.fulfilledResult {
            case .failure(let error):
                // If self failed then skip this step and fulfill the promise by passing along the error.
                promise.fail(with: error)

            case .success(let value):
                // Execute the task. The task will generally complete asynchronously but it can complete synchronously too (not that it makes any difference to the promise operation).
                do {
                    let nextValue = try mapper(value)
                    promise.succeed(with: nextValue)
                } catch {
                    promise.fail(with: error)
                }
            }
        }

        return promise
    }
}


// MARK: - Future mapping

public extension FutureResultable where Self: Operation {

    /// The returned future is fulfilled after the handler is executed.
    func mapFuture<U>(on executionQueue: OperationQueue = .main, using mapper: @escaping (Success) -> Future<U>) -> Future<U> {
        // Create and enqueue a promise which will be used as the return value.
        let promise = Promise<U>.make()

        // When self completes...
        executionQueue.addCompletionOperation(to: self) { completedOperation in
            if promise.isCancelled {
                return
            }
            switch completedOperation.fulfilledResult {
            case .failure(let error):
                // If self failed then skip this step and fulfill the promise by passing along the error.
                promise.fail(with: error)

            case .success(let value):
                let nextOperation = mapper(value)
                Promises.defaultOperationQueue.addCompletionOperation(to: nextOperation) { operation in
                    promise.fulfill(with: operation.fulfilledResult)
                }
            }
        }
        return promise
    }
}
