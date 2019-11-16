//
//  BlockingPromiseOperation.swift
//  Properations
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


public final class BlockingPromiseOperation<Success>: PromiseOperation<Success> {

    // MARK: State

    override var initialState: OperationStateCoordinator<FutureResult<Success>>.State {
        return .ready
    }

    public override var isConcurrent: Bool {
        return true
    }

    public override var isAsynchronous: Bool {
        return true
    }

    public override var isExecuting: Bool {
        return stateCoordinator.readState { $0.isExecuting }
    }

    public override var isFinished: Bool {
        return stateCoordinator.readState { $0.isFinished || $0.isCancelled }
    }

    private var executionBlock: ((Promise<Success>) -> Void)?


    // MARK: Instance life cycle

    public init(executionBlock: @escaping (Promise<Success>) -> Void) {
        self.executionBlock = executionBlock
        super.init()
    }


    // MARK: Actions

    public override func start() {
        stateCoordinator.transition(to: .executing) { currentState, _ in
            if currentState.isCancelled {
                return false // If the operation has been cancelled then ignore the result.
            }
            return true
        }
        stateCoordinator.readState { state in
            guard state.isExecuting else {
                return
            }
            self.executionBlock?(self)
            self.executionBlock = nil
        }
    }
}
