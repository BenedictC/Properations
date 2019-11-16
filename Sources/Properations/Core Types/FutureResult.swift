//
//  FutureResult.swift
//  Properations
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


// MARK: - FutureResult

#if swift(>=5)
// Swift 5 has a native result type
public typealias FutureResult<Success> = Result<Success, Error>
#else
// Define a result type for pre Swift 5 usage. This is only a subset of the functionality provided by the Result type in Swift 5.
public enum FutureResult<Success> {
    public typealias Failure = Error

    case success(Success)
    case failure(Failure)

    public func get() throws -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}
#endif


// MARK: - FutureResultable

public protocol FutureResultable {

    associatedtype Success

    var result: FutureResult<Success>? { get }
}


public extension FutureResultable {

    var isFulfilled: Bool {
        return result != nil
    }
}


// MARK: - Additional Accessors

public extension FutureResult {

    var successValue: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }

    var failureValue: Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }

    var isFailure: Bool {
        return !isSuccess
    }
}


// MARK: - FutureResult<Void> addition

public extension FutureResult where Success == Void {

    static var success: FutureResult<Void> {
        return FutureResult.success(())
    }
}
