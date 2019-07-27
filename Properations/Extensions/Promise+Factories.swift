//
//  Promise+Factories.swift
//  Properations
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


// MARK: - Factories

public extension Promise {

    static func make(on queue: OperationQueue? = Promises.defaultOperationQueue) -> Promise<Success> {
        let promise = Promise<Success>()
        queue?.addOperation(promise)
        return promise
    }

    static func makeFulfilled<T>(on queue: OperationQueue? = Promises.defaultOperationQueue, with result: FutureResult<T>) -> Promise<T> {
        let promise = Promise<T>()
        queue?.addOperation(promise)
        promise.fulfill(with: result)
        return promise
    }

    /// The returned future is fulfilled after the handler is executed.
    static func makeBlocking<T>(on queue: OperationQueue, executionQueue: OperationQueue = .main, executionTask: @escaping ((Promise<T>) -> Void) = { _ in }) -> Promise<T> {
        assert(queue != .main, "Blocking operations must not be enqueue on the main operation queue.")
        let promise = BlockingPromiseOperation<T>(executionBlock: { promise in
            if promise.isCancelled {
                return
            }
            executionQueue.addOperation { executionTask(promise) }
        })
        queue.addOperation(promise)
        return promise
    }

    /// The returned future is fulfilled after the handler is executed.
    static func make<T, Op: Operation>(on queue: OperationQueue? = Promises.defaultOperationQueue, awaitingCompletionOf operation: Op, executionQueue: OperationQueue = .main, completionHandler: @escaping (Op) throws -> T) -> Future<T> {
        let promise = Promise<T>.make(on: queue)
        executionQueue.addCompletionOperation(to: operation) { completedOp in
            if promise.isCancelled {
                return
            }
            do {
                let value = try completionHandler(completedOp)
                promise.succeed(with: value)
            } catch {
                promise.fail(with: error)
            }
        }
        return promise
    }
}
