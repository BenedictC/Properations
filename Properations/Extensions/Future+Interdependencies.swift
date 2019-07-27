//
//  Future+Interdependencies.swift
//  Properations
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


// MARK: - Cancel

public extension Operation {

    func cancel<T>(onFailureOf future: Future<T>) {
        Promises.defaultOperationQueue.addCompletionOperation(to: future) { future in
            if future.fulfilledResult.isFailure {
                self.cancel()
            }
        }
    }
}


// MARK: - Race

public extension Promises {

    private static let raceOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    // Result is fulfilled once on of the futures successfully completes
    static func race<T>(_ futures: [Future<T>]) -> Future<T> {
        let promise = Promise<T>.make()
        // Create a single failure operation that fires once all the futures have completed.
        let failureOp = BlockOperation()
        futures.forEach { failureOp.addDependency($0) }
        failureOp.addExecutionBlock {
            if promise.isCancelled {
                return
            }
            let errors = futures.map { $0.fulfilledResult.failureValue }
            let allFailed = !errors.contains(where: { $0 == nil })
            if allFailed {
                let error = ProperationsError.multipleErrors(errors)
                promise.fail(with: error)
            }
        }
        Promises.defaultOperationQueue.addOperation(failureOp)

        // Create a success operation for each future
        let raceWinnerHandler = { (winner: Future<T>) -> Void in
            guard promise.isResultFulfilled == false,
                let value = winner.fulfilledResult.successValue else {
                return
            }
            promise.succeed(with: value)
            failureOp.cancel()
        }
        // Add a completion handler for each future
        futures.forEach { future in
            Promises.raceOperationQueue.addCompletionOperation(to: future, completionHandler: raceWinnerHandler)
        }

        return promise
    }
}
