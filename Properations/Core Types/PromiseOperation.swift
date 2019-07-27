//
//  PromiseOperation.swift
//  Properations
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


public class PromiseOperation<Success>: FutureOperation<Success> {

    // MARK: State

    internal var initialState: OperationStateCoordinator<FutureResult<Success>>.State {
        return .preparing
    }

    internal lazy var stateCoordinator = OperationStateCoordinator<FutureResult<Success>>(operation: self, initialState: self.initialState)

    public override var result: FutureResult<Success>? {
        return stateCoordinator.readState { state in
            switch state {
            case .cancelled:
                return .failure(ProperationsError.cancelled)
            case . finished(let result):
                return result
            default:
                return nil
            }
        }
    }

    public override var isReady: Bool {
        return super.isReady && stateCoordinator.readState { $0.isPreparing == false }
    }

    
    // MARK: Actions

    public func fulfill(with result: FutureResult<Success>) {
        // Transition from preparing (which will trigger isReady KVO) to finished
        stateCoordinator.transition(to: .finished(result)) { currentState, _ in
            if currentState.isCancelled {
                return false // If the operation has been cancelled then ignore the result.
            }
            guard currentState.isFinished == false else {
                assertionFailure("Attempted to fulfill operation twice.") // If the operation has already finished then it's a programmer error to call fulfill again.
                return false
            }
            return true
        }
    }

    public func succeed(with value: Success) {
        fulfill(with: .success(value))
    }

    public func fail(with error: Error) {
        fulfill(with: .failure(error))
    }

    public override func cancel() {
        stateCoordinator.transition(to: .cancelled) { currentState, _ in
            if currentState.isFinished { // If the operation is already finished then do not allow it to transition to cancelled
                return false
            }
            super.cancel()
            return true
        }
    }
}


extension PromiseOperation where Success == Void {

    public func succeed() {
        fulfill(with: .success)
    }
}
