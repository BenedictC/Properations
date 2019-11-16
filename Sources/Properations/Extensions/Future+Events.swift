//
//  Future+Events.swift
//  Properations
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


public extension FutureResultable where Self: Operation {

    /// The returned future is fulfilled before the handler is executed.
    @discardableResult
    func onCompletion(on executionQueue: OperationQueue = .main, resultHandler: @escaping (FutureResult<Success>) -> Void) -> Future<Success> {
        let promise = Promise<Success>.make()
        executionQueue.addCompletionOperation(to: self) { future in
            if promise.isCancelled {
                return
            }
            let result = future.fulfilledResult
            // Fulfill the promise before excuting the handler so that if the handler references the promise the result will fulfilled.
            promise.fulfill(with: result)
            resultHandler(result)
        }
        return promise
    }

    /// The returned future is fulfilled before the handler is executed.
    @discardableResult
    func onSuccess(on executionQueue: OperationQueue = .main, valueHandler: @escaping (Success) -> Void) -> Future<Success> {
        let promise = Promise<Success>.make()

        // When self completes...
        executionQueue.addCompletionOperation(to: self) { future in
            if promise.isCancelled {
                return
            }
            do {
                let value = try future.fulfilledResult.get()
                // Fulfill the promise before excuting the handler so that if the handler references the promise the result will fulfilled.
                promise.succeed(with: value)
                valueHandler(value)
            } catch {
                promise.fail(with: error)
            }
        }
        return promise
    }

    /// The returned future is fulfilled before the handler is executed.
    @discardableResult
    func onFailure(on executionQueue: OperationQueue = .main, errorHandler: @escaping (Error) -> Void) -> Future<Success> {
        // Create and enqueue a promise which will be used as the return value.
        let promise = Promise<Success>.make()
        executionQueue.addCompletionOperation(to: self) { future in
            if promise.isCancelled {
                return
            }
            do {
                let value = try future.fulfilledResult.get()
                promise.succeed(with: value)
            } catch {
                // Fulfill the promise before excuting the handler so that if the handler references the promise the result will fulfilled.
                promise.fail(with: error)
                errorHandler(error)
            }
        }
        return promise
    }

    @discardableResult
    func onCancel(on executionQueue: OperationQueue = .main, cancelationHandler: @escaping () -> Void) -> Future<Success> {
        // Create and enqueue a promise which will be used as the return value.
        let promise = Promise<Success>.make()
        executionQueue.addCompletionOperation(to: self) { future in
            if promise.isCancelled {
                return
            }
            do {
                // TODO: should we skip execution if promise.isCancelled == true?
                let value = try future.fulfilledResult.get()
                promise.succeed(with: value)
            } catch ProperationsError.cancelled {
                let error = ProperationsError.cancelled
                // Fulfill the promise before excuting the handler so that if the handler references the promise the result will fulfilled.
                promise.fail(with: error)
                cancelationHandler()
            } catch {
                promise.fail(with: error)
            }

        }
        return promise
    }
}
