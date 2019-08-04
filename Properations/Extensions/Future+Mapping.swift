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

    func compactMapToValue<U>(on executionQueue: OperationQueue = .main, using transform: @escaping (Success) throws -> U?) -> Future<U> {
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
                    guard let nextValue = try transform(value) else {
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

    func mapToValue<U>(on executionQueue: OperationQueue = .main, using transform: @escaping (Success) throws -> U) -> Future<U> {
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
                    let nextValue = try transform(value)
                    promise.succeed(with: nextValue)
                } catch {
                    promise.fail(with: error)
                }
            }
        }

        return promise
    }
}


// MARK: - Collection mapping

public extension FutureResultable where Self: Operation, Success: Collection {

    func compactMapElementsToValue<U>(on executionQueue: OperationQueue = .main, using transform: @escaping (Success.Element) throws -> U?) -> Future<[U]> {
        let promise = Promises.make(promising: [U].self)

        executionQueue.addCompletionOperation(to: self) { completedOp in
            do {
                let value = try completedOp.fulfilledResult.get()
                let collection = try value.compactMap(transform)
                promise.succeed(with: collection)
            } catch {
                promise.fail(with: error)
            }
        }
        return promise
    }

    func compactMapElementsToFuture<U>(on executionQueue: OperationQueue = .main, using transform: @escaping (Success.Element) throws -> Future<U>?) -> Future<[U]> {
        let promise = Promises.make(promising: [U].self)

        executionQueue.addCompletionOperation(to: self) { completedOp in
            do {
                // Map the elements to futures
                let value = try completedOp.fulfilledResult.get()
                let futures = try value.compactMap(transform)

                // Create an operation that fires once all futures are fulfilled
                let futuresCompletionOp = BlockOperation()
                futures.forEach { futuresCompletionOp.addDependency($0) }

                // Once all the futures are fulfilled ...
                futuresCompletionOp.addExecutionBlock {
                    do {
                        // ... collect the futures value's ...
                        let result = try futures.map { try $0.fulfilledResult.get() }
                        promise.succeed(with: result)
                    } catch {
                        // ... but if at least one fails then fail the result.
                        let errors = futures.map { $0.fulfilledResult.failureValue }
                        let error = ProperationsError.multipleErrors(errors)
                        promise.fail(with: error)
                    }
                }
                // Enqueue completion op *after* execution block is added. If enqueued before then the op might execute before we add block is added.
                Promises.defaultOperationQueue.addOperation(futuresCompletionOp)
            } catch {
                promise.fail(with: error)
            }
        }
        return promise
    }
    
    func mapElementsToValue<U>(on executionQueue: OperationQueue = .main, using transform: @escaping (Success.Element) throws -> U) -> Future<[U]> {
        let promise = Promises.make(promising: [U].self)

        executionQueue.addCompletionOperation(to: self) { completedOp in
            do {
                let value = try completedOp.fulfilledResult.get()
                let collection = try value.map(transform)
                promise.succeed(with: collection)
            } catch {
                promise.fail(with: error)
            }
        }
        return promise
    }

    func mapElementsToFuture<U>(on executionQueue: OperationQueue = .main, using transform: @escaping (Success.Element) throws -> Future<U>) -> Future<[U]> {
        let promise = Promises.make(promising: [U].self)

        executionQueue.addCompletionOperation(to: self) { completedOp in
            do {
                // Map the elements to futures
                let value = try completedOp.fulfilledResult.get()
                let futures = try value.map(transform)

                // Create an operation that fires once all futures are fulfilled
                let futuresCompletionOp = BlockOperation()
                futures.forEach { futuresCompletionOp.addDependency($0) }

                // Once all the futures are fulfilled ...
                futuresCompletionOp.addExecutionBlock {
                    do {
                        // ... collect the futures value's ...
                        let result = try futures.map { try $0.fulfilledResult.get() }
                        promise.succeed(with: result)
                    } catch {
                        // ... but if at least one fails then fail the result.
                        let errors = futures.map { $0.fulfilledResult.failureValue }
                        let error = ProperationsError.multipleErrors(errors)
                        promise.fail(with: error)
                    }
                }
                // Enqueue completion op *after* execution block is added. If enqueued before then the op might execute before we add block is added.
                Promises.defaultOperationQueue.addOperation(futuresCompletionOp)
            } catch {
                promise.fail(with: error)
            }
        }
        return promise
    }
}


// MARK: - Future mapping

public extension FutureResultable where Self: Operation {

    /// The returned future is fulfilled after the handler is executed.
    func mapToFuture<U>(on executionQueue: OperationQueue = .main, using transform: @escaping (Success) -> Future<U>) -> Future<U> {
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
                let nextOperation = transform(value)
                Promises.defaultOperationQueue.addCompletionOperation(to: nextOperation) { operation in
                    promise.fulfill(with: operation.fulfilledResult)
                }
            }
        }
        return promise
    }
}
