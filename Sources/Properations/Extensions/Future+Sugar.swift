//
//  Future+Sugar.swift
//  Properations
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


// MARK: - Combine

// TODO: These functions fail when the expression contains more than 2 futures

//public func +<L, R, FL: ResultableOp, FR: ResultableOp>(lhs: FL, rhs: FR) -> Future<(L, R)> where FL.Success == L, FR.Success == R {
//    return Promises.combine(lhs, rhs)
//}
//
//public func +<L, R1, R2, LF: Future<L>, RF: Future<(R1, R2)>>(lhs: LF, rhs: RF) -> Future<(L, R1, R2)> {
//    return Promises.combine(lhs, rhs)
//        .mapToValue { ($0, $1.0, $1.1) }
//}
//
//public func +<L, R1, R2, R3, LF: Future<L>, RF: Future<(R1, R2, R3)>>(lhs: LF, rhs: RF) -> Future<(L, R1, R2, R3)> {
//    return Promises.combine(lhs, rhs)
//        .mapToValue { ($0, $1.0, $1.1, $1.2) }
//}
//
//public func +<LF: ResultableOp, RF: ResultableOp, L1, L2>(lhs: LF, rhs: RF) -> Future<(L1, L2, RF.Success)> where LF.Success == (L1, L2) {
//    return Promises.combine(lhs, rhs)
//        .mapToValue { ($0.0, $0.1, $1) }
//}
//
//public func +<L1, L2, R, LF: Future<(L1, L2)>, RF: Future<R>>(lhs: LF, rhs: RF) -> Future<(L1, L2, R)> {
//    return Promises.combine(lhs, rhs)
//        .mapToValue { ($0.0, $0.1, $1) }
//}
//
//public func +<L1, L2, L3, R, LF: Future<(L1, L2, L3)>, RF: Future<R>>(lhs: LF, rhs: RF) -> Future<(L1, L2, L3, R)> {
//    return Promises.combine(lhs, rhs)
//        .mapToValue { ($0.0, $0.1, $0.2, $1) }
//}
//
//public func +<L1, L2, R1, R2, LF: Future<(L1, L2)>, RF: Future<(R1, R2)>>(lhs: LF, rhs: RF) -> Future<(L1, L2, R1, R2)> {
//    return Promises.combine(lhs, rhs)
//        .mapToValue { ($0.0, $0.1, $1.0, $1.1) }
//}


// MARK: - Race

public func || <T>(lhs: Future<T>, rhs: Future<T>) -> Future<T> {
    return Promises.race([lhs, rhs])
}


// MARK: - Static methods as Array extensions

public extension Collection {

    func collectFutures<S>() -> Future<[S]> where Element: Future<S> {
        return Promises.collect(self)
    }

    func raceFutures<S>() -> Future<S> where Element: Future<S> {
        return Promises.race(self)
    }
}


// MARK: - Factories with generics as parameters

public extension Promises {

    static func make<T>(on queue: OperationQueue? = Promises.defaultOperationQueue, promising type: T.Type) -> Promise<T> {
        return Promise<T>.make(on: queue)
    }

    static func makeFulfilled<T>(on queue: OperationQueue? = Promises.defaultOperationQueue, with result: FutureResult<T>) -> Promise<T> {
        return Promise<T>.makeFulfilled(on: queue, with: result)
    }

    static func makeBlocking<T>(on queue: OperationQueue, promising type: T.Type, executionTask: @escaping ((Promise<T>) -> Void) = { _ in }) -> Promise<T> {
        return Promise<T>.makeBlocking(on: queue, executionTask: executionTask)    
    }

    static func make<T, Op: Operation>(on queue: OperationQueue = Promises.defaultOperationQueue, awaitingCompletionOf operation: Op, completionHandler: @escaping (Op) throws -> T) -> Future<T> {
        return Promise<T>.make(awaitingCompletionOf: operation, completionHandler: completionHandler)
    }
}
