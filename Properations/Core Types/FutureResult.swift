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

    var isResultFulfilled: Bool {
        return result != nil
    }
}


// MARK: - Result helpers

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


public extension FutureResult where Success == Void {

    #if swift(>=5)
    static var success: Result<Void, Failure> {
        return Result.success(())
    }
    #else
    static var success: FutureResult<Void> {
        return FutureResult.success(())
    }
    #endif
}
