//
//  Future+Sugar.swift
//  Properations
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


// MARK: - Combine

public func +<U, V>(lhs: Future<U>, rhs: Future<V>) -> Future<(U, V)> {
    return Promises.combine(lhs, rhs)
}


// MARK: - Race

public func || <T>(lhs: Future<T>, rhs: Future<T>) -> Future<T> {
    return Promises.race([lhs, rhs])
}


// MARK: - Static methods as free functions

public func collect<T>( _ futures: [Future<T>]) -> Future<[T]> {
    return Promises.collect(futures)
}

public func combine<S1, S2>(_ future1: Future<S1>, _ future2: Future<S2>) -> Future<(S1, S2)> {
    return Promises.combine(future1, future2)
}

public func combine<S1, S2, S3>(_ future1: Future<S1>, _ future2: Future<S2>, _ future3: Future<S3>) -> Future<(S1, S2, S3)> {
    return Promises.combine(future1, future2, future3)
}

public func combine<S1, S2, S3, S4>(_ future1: Future<S1>, _ future2: Future<S2>, _ future3: Future<S3>, _ future4: Future<S4>) -> Future<(S1, S2, S3, S4)> {
    return Promises.combine(future1, future2, future3, future4)
}

public func race<T>(_ futures: [Future<T>]) -> Future<T> {
    return Promises.race(futures)
}


// MARK: - Static methods as Array extensions

public extension Array {

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
