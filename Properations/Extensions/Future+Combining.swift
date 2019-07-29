//
//  Future+Combining.swift
//  Properations
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


// MARK: - Combining homogeneous results

public extension Promises {

    static func collect<T, C: Collection>( _ futures: C) -> Future<[T]> where C.Element: Future<T> {
        return makeFuture(byCombining: futures) { () throws -> [T] in
            do {
                return try futures.map { try $0.fulfilledResult.get() }
            } catch {
                let errors = futures.map { $0.fulfilledResult.failureValue }
                throw ProperationsError.multipleErrors(errors)
            }
        }
    }
}


// MARK: - Combining heterogeneous results

public extension Promises {

    static func combine<S1, S2>(_ future1: Future<S1>, _ future2: Future<S2>) -> Future<(S1, S2)> {
        return makeFuture(byCombining: [future1, future2]) {
            do {
                let s1 = try future1.fulfilledResult.get()
                let s2 = try future2.fulfilledResult.get()
                return (s1, s2)
            } catch {
                throw ProperationsError.multipleErrors([
                    future1.fulfilledResult.failureValue,
                    future2.fulfilledResult.failureValue,
                    ])
            }
        }
    }

    static func combine<S1, S2, S3>(_ future1: Future<S1>, _ future2: Future<S2>, _ future3: Future<S3>) -> Future<(S1, S2, S3)> {
        return makeFuture(byCombining: [future1, future2, future3]) {
            do {
                let s1 = try future1.fulfilledResult.get()
                let s2 = try future2.fulfilledResult.get()
                let s3 = try future3.fulfilledResult.get()
                return (s1, s2, s3)
            } catch {
                throw ProperationsError.multipleErrors([
                    future1.fulfilledResult.failureValue,
                    future2.fulfilledResult.failureValue,
                    future3.fulfilledResult.failureValue,
                    ])
            }
        }
    }

    static func combine<S1, S2, S3, S4>(_ future1: Future<S1>, _ future2: Future<S2>, _ future3: Future<S3>, _ future4: Future<S4>) -> Future<(S1, S2, S3, S4)> {
        return makeFuture(byCombining: [future1, future2, future3, future4]) {
            do {
                let s1 = try future1.fulfilledResult.get()
                let s2 = try future2.fulfilledResult.get()
                let s3 = try future3.fulfilledResult.get()
                let s4 = try future4.fulfilledResult.get()
                return (s1, s2, s3, s4)
            } catch {
                throw ProperationsError.multipleErrors([
                    future1.fulfilledResult.failureValue,
                    future2.fulfilledResult.failureValue,
                    future3.fulfilledResult.failureValue,
                    future4.fulfilledResult.failureValue,
                    ])
            }
        }
    }
}


// MARK: - Operation handling

private extension Promises {

    static func makeFuture<T, C: Collection>(byCombining dependencies: C, using handler: @escaping () throws -> T) -> Future<T> where C.Element: Operation {
        let promise = Promise<T>.make()

        // Create an operation ...
        let reduceOperation = BlockOperation()
        // ... that is dependent on the child operations ...
        dependencies.forEach { reduceOperation.addDependency($0) }
        // ... runs the reduce block and fulfills the promise ...
        reduceOperation.addExecutionBlock {
            if promise.isCancelled {
                return
            }
            do {
                let value = try handler()
                promise.succeed(with: value)
            } catch {
                promise.fail(with: error)
            }
        }
        // ... and executed on the execution queue
        Promises.defaultOperationQueue.addOperation(reduceOperation)

        return promise
    }
}
