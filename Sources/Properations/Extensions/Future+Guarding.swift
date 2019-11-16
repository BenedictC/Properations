//
//  Future+Guarding.swift
//  Properations
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


public extension FutureResultable where Self: Operation {

    /// The returned future is fulfilled after the handler is executed.
    func ensure(on executionQueue: OperationQueue = .main, handler: @escaping (Success) -> Bool) -> Future<Success> {
        let promise = Promise<Success>.make()
        executionQueue.addCompletionOperation(to: self) { future in
            if promise.isCancelled {
                return
            }
            let result: FutureResult<Success>
            switch future.fulfilledResult {
            case .success(let value):
                result = handler(value) ? .success(value) : .failure(ProperationsError.ensureFailed)

            case .failure(let error):
                result = .failure(error)
            }
            promise.fulfill(with: result)
        }
        return promise
    }
}
