//
//  OperationStateCoordinatorTests.swift
//  ProperationsTests
//
//  Created by Benedict Cohen on 27/07/2019.
//  Copyright © 2019 Benedict Cohen. All rights reserved.
//

import XCTest
@testable import Properations


enum UnwrapError: Error {
    case unexpectedNil
}


extension Optional {

    func unwrap() throws -> Wrapped {
        switch self {
        case .none:
            throw UnwrapError.unexpectedNil
        case .some(let value):
            return value
        }
    }
}


class OperationStateCoordinatorTests: XCTestCase {

    // MARK: Expected

    func testExpectedTransitionPreparingToReady() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .preparing)

        let actual = try coordinator.transition(to: .ready)

        let expectedNewState = OperationState<Bool>.ready
        XCTAssertEqual(try actual.unwrap().newState, expectedNewState)
    }

    func testExpectedTransitionPreparingToCancelled() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .preparing)

        let actual = try coordinator.transition(to: .cancelled)

        let expectedNewState = OperationState<Bool>.cancelled
        XCTAssertEqual(try actual.unwrap().newState, expectedNewState)
    }

    func testExpectedTransitionReadyToExecuting() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .ready)

        let actual = try coordinator.transition(to: .executing)

        let expectedNewState = OperationState<Bool>.executing
        XCTAssertEqual(try actual.unwrap().newState, expectedNewState)
    }

    func testExpectedTransitionReadyToCancelled() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .ready)

        let actual = try coordinator.transition(to: .cancelled)

        let expectedNewState = OperationState<Bool>.cancelled
        XCTAssertEqual(try actual.unwrap().newState, expectedNewState)
    }

    func testExpectedTransitionExecutingToFinished() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .executing)

        let actual = try coordinator.transition(to: .finished(true))

        let expectedNewState = OperationState<Bool>.finished(true)
        XCTAssertEqual(try actual.unwrap().newState, expectedNewState)
    }

    func testExpectedTransitionExecutingToCancelled() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .executing)

        let actual = try coordinator.transition(to: .cancelled)

        let expectedNewState = OperationState<Bool>.cancelled
        XCTAssertEqual(try actual.unwrap().newState, expectedNewState)
    }


    // MARK: Strange but benign

    func testStrangeButBenignTranstionPreparingToPreparing() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .executing)

        let actual = try coordinator.transition(to: .cancelled)

        let expectedNewState = OperationState<Bool>.cancelled
        XCTAssertEqual(try actual.unwrap().newState, expectedNewState)
    }

    func testStrangeButBenignTranstionReadyToReady() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .ready)

        let actual = try coordinator.transition(to: .ready)

        let expectedNewState = OperationState<Bool>.ready
        XCTAssertEqual(try actual.unwrap().newState, expectedNewState)
    }

    func testStrangeButBenignTranstionReadyToFinished() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .ready)

        let actual = try coordinator.transition(to: .finished(true))

        let expectedNewState = OperationState<Bool>.finished(true)
        XCTAssertEqual(try actual.unwrap().newState, expectedNewState)
    }

    func testStrangeButBenignTranstionExecutingToExecuting() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .executing)

        let actual = try coordinator.transition(to: .executing)

        let expectedNewState = OperationState<Bool>.executing
        XCTAssertEqual(try actual.unwrap().newState, expectedNewState)
    }

    func testStrangeButBenignTranstionCancelledToCancelled() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .cancelled)

        let actual = try coordinator.transition(to: .cancelled)

        let expectedNewState = OperationState<Bool>.cancelled
        XCTAssertEqual(try actual.unwrap().newState, expectedNewState)
    }


    // MARK: Invalid

    func testInvalidTransitionPreparingToExecuting() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .preparing)

        XCTAssertThrowsError(try coordinator.transition(to: .executing))
    }

    func testInvalidTransitionPreparingToFinished() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .preparing)

        XCTAssertThrowsError(try coordinator.transition(to: .finished(true)))
    }

    func testInvalidTransitionReadyToPreparing() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .ready)

        XCTAssertThrowsError(try coordinator.transition(to: .preparing))
    }

    func testInvalidTransitionExecutingToPreparing() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .executing)

        XCTAssertThrowsError(try coordinator.transition(to: .preparing))
    }

    func testInvalidTransitionExecutingToReady() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .executing)

        XCTAssertThrowsError(try coordinator.transition(to: .ready))
    }

    func testInvalidTransitionCancelledToPreparing() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .cancelled)

        XCTAssertThrowsError(try coordinator.transition(to: .preparing))
    }

    func testInvalidTransitionCancelledToReady() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .cancelled)

        XCTAssertThrowsError(try coordinator.transition(to: .ready))
    }

    func testInvalidTransitionCancelledToExecuting() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .preparing)

        XCTAssertThrowsError(try coordinator.transition(to: .finished(true)))
    }

    func testInvalidTransitionCancelledToFinished() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .cancelled)

        XCTAssertThrowsError(try coordinator.transition(to: .finished(true)))
    }

    func testInvalidTransitionFinishedToPreparing() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .finished(true))

        XCTAssertThrowsError(try coordinator.transition(to: .preparing))
    }

    func testInvalidTransitionFinishedToReady() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .finished(true))

        XCTAssertThrowsError(try coordinator.transition(to: .ready))
    }

    func testInvalidTransitionFinishedToExecuting() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .finished(true))

        XCTAssertThrowsError(try coordinator.transition(to: .executing))
    }

    func testInvalidTransitionFinishedToCancelled() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .finished(true))

        XCTAssertThrowsError(try coordinator.transition(to: .cancelled))
    }

    func testInvalidTransitionFinishedToFinished() throws {
        let operation = Operation()
        let coordinator = OperationStateCoordinator<Bool>(operation: operation, initialState: .finished(true))

        XCTAssertThrowsError(try coordinator.transition(to: .finished(true)))
    }
}
