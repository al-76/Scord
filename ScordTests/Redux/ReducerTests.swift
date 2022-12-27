//
//  ReducerTests.swift
//  ScordTests
//
//  Created by Vyacheslav Konopkin on 27.12.2022.
//

import Combine
import XCTest

@testable import Scord

struct MainReducer: Reducer {
    struct State: Equatable {
        var increment: IncrementReducer.State
    }

    enum Action {
        case increment(IncrementReducer.Action)
    }

    let incrementReducer: IncrementReducer

    func reduce(state: inout State, action: Action) -> Scord.Effect<Action> {
        switch action {
        case .increment(let action):
            return incrementReducer
                .reduce(state: &state.increment, action: action)
                .map(Action.increment)
                .eraseToAnyPublisher()
        }
    }
}

struct IncrementReducer: Reducer {
    struct State: Equatable {
        var counter: Int
    }

    enum Action {
        case increment
        case incrementResult(Int)
    }

    func reduce(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .increment:
            return Future { [counter = state.counter] promise in
                promise(.success(.incrementResult(counter + 1)))
            }
            .eraseToAnyPublisher()

        case .incrementResult(let counter):
            state.counter = counter
        }

        return noEffect()
    }
}

final class ReducerTests: XCTestCase {
    func testSend() {
        // Arrange
        let counter = 1099
        let store = StoreOf<IncrementReducer>(state: .init(counter: counter),
                                              reducer: IncrementReducer())

        // Act
        store.submit(.increment)

        // Assert
        XCTAssertEqual(try awaitPublisher(store.$state.dropFirst()),
                       .init(counter: counter + 1))
    }

    func testScope() {
        // Arrange
        let counter = 1099
        let store = StoreOf<MainReducer>(state: .init(increment: .init(counter: counter)),
                                         reducer: MainReducer(incrementReducer: IncrementReducer()))
        let scopedStore = store.scope(onState: \.increment,
                                      onAction: MainReducer.Action.increment,
                                      IncrementReducer.self)

        // Act
        scopedStore.submit(.increment)

        // Assert
        XCTAssertEqual(try awaitPublisher(store.$state.dropFirst()),
                       .init(increment: .init(counter: counter + 1)))
        XCTAssertEqual(try awaitPublisher(scopedStore.$state.dropFirst()),
                       .init(counter: counter + 1))
    }

    func testScopeReversed() {
        // Arrange
        let counter = 1099
        let store = StoreOf<MainReducer>(state: .init(increment: .init(counter: counter)),
                                         reducer: MainReducer(incrementReducer: IncrementReducer()))
        let scopedStore = store.scope(onState: \.increment,
                                      onAction: MainReducer.Action.increment,
                                      IncrementReducer.self)

        // Act
        store.submit(.increment(.increment))

        // Assert
        XCTAssertEqual(try awaitPublisher(store.$state.dropFirst()),
                       .init(increment: .init(counter: counter + 1)))
        XCTAssertEqual(try awaitPublisher(scopedStore.$state.dropFirst()),
                       .init(counter: counter + 1))
    }
}
