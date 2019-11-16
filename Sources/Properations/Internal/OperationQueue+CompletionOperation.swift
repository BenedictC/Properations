//
//  OperationQueue+CompletionOperation.swift
//  Properations
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


protocol _Operationable { }

extension Operation: _Operationable {}


private extension _Operationable where Self: Operation {

     func makeCompletionOperation(with completionHandler: @escaping (Self) -> Void) -> Operation {
        let operation = BlockOperation()
        operation.addExecutionBlock {
            completionHandler(self)
        }
        operation.addDependency(self)
        return operation
    }
}


extension OperationQueue {

    @discardableResult
    func addCompletionOperation<T: Operation>(to operation: T, completionHandler: @escaping (T) -> Void) -> Operation {
        let completionOperation = operation.makeCompletionOperation(with: completionHandler)
        addOperation(completionOperation)
        return completionOperation
    }
}
