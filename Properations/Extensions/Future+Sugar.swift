//
//  Future+Sugar.swift
//  Properations
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


// MARK: - Combine

public func +<L, R>(lhs: Future<L>, rhs: Future<R>) -> Future<(L, R)> {
    return Promises.combine(lhs, rhs)
}

public func +<L, R1, R2>(lhs: Future<L>, rhs: Future<(R1, R2)>) -> Future<(L, R1, R2)> {
    return Promises.combine(lhs, rhs)
        .mapValue { ($0, $1.0, $1.1) }
}

public func +<L, R1, R2, R3>(lhs: Future<L>, rhs: Future<(R1, R2, R3)>) -> Future<(L, R1, R2, R3)> {
    return Promises.combine(lhs, rhs)
        .mapValue { ($0, $1.0, $1.1, $1.2) }
}

public func +<L1, L2, R>(lhs: Future<(L1, L2)>, rhs: Future<R>) -> Future<(L1, L2, R)> {
    return Promises.combine(lhs, rhs)
        .mapValue { ($0.0, $0.1, $1) }
}

public func +<L1, L2, L3, R>(lhs: Future<(L1, L2, L3)>, rhs: Future<R>) -> Future<(L1, L2, L3, R)> {
    return Promises.combine(lhs, rhs)
        .mapValue { ($0.0, $0.1, $0.2, $1) }
}

public func +<L1, L2, R1, R2>(lhs: Future<(L1, L2)>, rhs: Future<(R1, R2)>) -> Future<(L1, L2, R1, R2)> {
    return Promises.combine(lhs, rhs)
        .mapValue { ($0.0, $0.1, $1.0, $1.1) }
}


// MARK: - Race

public func || <T>(lhs: Future<T>, rhs: Future<T>) -> Future<T> {
    return Promises.race([lhs, rhs])
}


// MARK: - Static methods as free functions

public func collectFutures<T, C: Collection>( _ futures: C) -> Future<[T]> where C.Element: Future<T> {
    return Promises.collect(futures)
}

public func combineFutures<S1, S2>(_ future1: Future<S1>, _ future2: Future<S2>) -> Future<(S1, S2)> {
    return Promises.combine(future1, future2)
}

public func combineFutures<S1, S2, S3>(_ future1: Future<S1>, _ future2: Future<S2>, _ future3: Future<S3>) -> Future<(S1, S2, S3)> {
    return Promises.combine(future1, future2, future3)
}

public func combineFutures<S1, S2, S3, S4>(_ future1: Future<S1>, _ future2: Future<S2>, _ future3: Future<S3>, _ future4: Future<S4>) -> Future<(S1, S2, S3, S4)> {
    return Promises.combine(future1, future2, future3, future4)
}

public func raceFutures<T, C: Collection>(_ futures: C) -> Future<T> where C.Element: Future<T> {
    return Promises.race(futures)
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


// MARK: - Factories

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
