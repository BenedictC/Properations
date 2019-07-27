//
//  Future+Timing.swift
//  Properations
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


// MARK: - Timing

extension FutureResultable where Self: Operation {

    public func delay(for interval: DispatchTimeInterval) -> Future<Success> {
        let promise = Promise<Success>.make()

        OperationQueue.main.addCompletionOperation(to: self) { future in
            switch future.fulfilledResult {
            case .failure(let error):
                promise.fail(with: error)
                
            case .success(let value):
                DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                    promise.succeed(with: value)
                }
            }
        }
        return promise
    }
}
