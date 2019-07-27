//
//  FutureOperation.swift
//  Properations
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


public class FutureOperation<Success>: Operation, FutureResultable {

    public var result: FutureResult<Success>? { return nil }
}


// MARK: - FutureResultable accessors

internal extension FutureResultable where Self: Operation {

    var fulfilledResult: FutureResult<Success> {
        guard isFinished else {
            fatalError("fulfilledResult called before operation is finished.")
        }
        guard let result = result else {
            fatalError("result not set after operation is finished.")
        }
        return result
    }
}
