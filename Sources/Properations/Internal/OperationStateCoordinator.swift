//
//  OperationStateCoordinator.swift
//  Properations
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import Foundation


// MARK: - OperationState

internal enum OperationState <T> {

    case preparing // .preparing is a sudo-state. It's allows us to express `isReady == false`
    case ready
    case executing
    case finished(T)
    case cancelled


    // MARK: State checking

    var isPreparing: Bool {
        switch self {
        case .preparing: return true
        default: return false
        }
    }

    var isReady: Bool {
        switch self {
        case .ready: return true
        default: return false
        }
    }

    var isExecuting: Bool {
        switch self {
        case .executing: return true
        default: return false
        }
    }

    var isFinished: Bool {
        switch self {
        case .finished: return true
        default: return false
        }
    }

    var isCancelled: Bool {
        switch self {
        case .cancelled: return true
        default: return false
        }
    }

    var finishedValue: T? {
        if case .finished(let value) = self {
            return value
        }
        return nil
    }


    // MARK: Key paths

    fileprivate var associatedKeyPaths: [String] {
        // We can't use fancy Swift 4 keypaths because the APIs that uses them aren't available on iOS 10 (use of them silently fails).
        switch self {
        case .preparing: return ["isReady"] // .preparing is a sudo-state. It's allows us to express `isReady == false`
        case .ready: return ["isReady"]
        case .executing: return ["isExecuting"]
        case .finished: return ["isExecuting", "isFinished"]
        case .cancelled: return ["isExecuting", "isCancelled", "isFinished"]
        }
    }


    // MARK: Validation

    func isValidNextState(_ nextState: OperationState<T>) -> Bool {
        // Check that the state transition is valid.
        switch (self, nextState) {

        // Expected
        case (.preparing, .ready),
             (.preparing, .cancelled),
             (.ready, .executing),
             (.ready, .cancelled),
             (.executing, .finished),
             (.executing, .cancelled):
            return true

        // Strange but benign
        case (.preparing, .preparing),
             (.ready, .ready),
             (.ready, .finished), // Hmmm. Is this acceptable?
        (.executing, .executing),
        (.cancelled, .cancelled):
            return true

        // Oppies!
        case (.preparing, .executing),
             (.preparing, .finished),
             (.ready, .preparing),
             (.executing, .preparing),
             (.executing, .ready),
             (.cancelled, .preparing),
             (.cancelled, .ready),
             (.cancelled, .executing),
             (.cancelled, .finished),
             (.finished, .preparing),
             (.finished, .ready),
             (.finished, .executing),
             (.finished, .cancelled),
             (.finished, .finished):
            return false
        }
    }
}


extension OperationState: Equatable where T: Equatable {

}


// MARK: - Sugar

extension OperationState where T == Void {
    static var finished: OperationState<Void> = .finished(())
}


// MARK: - OperationStateCoordinatorError

enum OperationStateCoordinatorError: Error {
    case invalidTransition
}


// MARK: - OperationStateCoordinator

internal class OperationStateCoordinator<T> {

    typealias State = OperationState<T>


    // MARK: Properties

    weak private(set) var operation: Operation?

    private var state: State

    private let lock = NSRecursiveLock() // Used to avoid recursive deadlocks


    // MARK: Instance life cycle

    init(operation: Operation, initialState: State = .ready) {
        self.operation = operation
        self.state = initialState
    }


    // MARK: Concurrency

    private func sync<T>(block: () throws -> T) rethrows -> T {
        lock.lock(before: .distantFuture)
        defer {
            lock.unlock()
        }
        return try block()
    }


    // MARK: Accessors

    func readState<T>(closure: (State) throws -> T) rethrows -> T {
        return try sync {
            return try closure(state)
        }
    }

    private func writeState(closure: (State) throws -> State?) rethrows {
        try sync {
            let oldValue = state
            guard let newValue = try closure(state) else {
                return
            }

            // Update value and fire KVO notifications
            let affectedKeyPaths = Set(oldValue.associatedKeyPaths + newValue.associatedKeyPaths)
            affectedKeyPaths.forEach { operation?.willChangeValue(forKey: $0) }
            state = newValue
            affectedKeyPaths.forEach { operation?.didChangeValue(forKey: $0) }
        }
    }

    @discardableResult
    func transition(to newState: State, providing: (_ currentState: State, _ newState: State) throws -> Bool = OperationStateCoordinator.defaultTransitionHandler) rethrows -> (oldState: State, newState: State)? {
        var result: (oldState: State, newState: State)?
        try writeState { currentState in
            let shouldTransition = try providing(currentState, newState)
            result = shouldTransition ? (currentState, newState) : nil
            return result?.newState
        }
        return result
    }

    private static func defaultTransitionHandler(currentState: State, newState: State) throws -> Bool {
        if currentState.isValidNextState(newState) {
            return true
        }
        throw OperationStateCoordinatorError.invalidTransition
    }
}
