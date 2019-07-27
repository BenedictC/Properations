//
//  ProperationsConstants.swift
//  Properations
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


// MARK: - Typealias convieniences

public typealias Future<T> = FutureOperation<T>
public typealias Promise<T> = PromiseOperation<T>


// MARK: - Errors

public enum ProperationsError: Error {
    case cancelled
    case compactMapReturnedNil
    case ensureFailed
    case multipleErrors([Error?])
}


// MARK: - Promises namespace

/// The Promises namespace exists because Promise is a generic class which means that calling a static func would require specifing a type which is ugly.
public enum Promises {

}


// MARK: - Operation Queue
extension Promises {

    public static let defaultOperationQueue = OperationQueue() // queue.maxConcurrentOperationCount defaults to NSOperationQueueDefaultMaxConcurrentOperationCount
}

