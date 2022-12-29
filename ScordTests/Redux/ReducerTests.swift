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
        var increment: IncrementReducer.State = .init()
    }

    enum Action {
        case increment(IncrementReducer.Action)

        // TODO: to get rid of a boilerplate
        func getIncrementAction() -> IncrementReducer.Action? {
            switch self {
            case .increment(let action):
                return action
            }
        }
    }

    var children: some Reducer<State, Action> {
        Scope(statePath: \.increment,
              mapAction: { $0.getIncrementAction() },
              mapScopedAction: MainReducer.Action.increment,
              reducer: IncrementReducer())

        EmptyReducer()

        for _ in 0...2 {
            EmptyReducer()
        }
    }
}

struct IncrementReducer: Reducer {
    struct State: Equatable {
        var value: Int = 0
    }

    enum Action {
        case increment
        case incrementResult(Int)
    }

    func reduce(state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .increment:
            return Future { [value = state.value] promise in
                promise(.success(.incrementResult(value + 1)))
            }
            .eraseToAnyPublisher()

        case .incrementResult(let value):
            state.value = value
        }

        return noEffect()
    }
}

final class ReducerTests: XCTestCase {
    func testSend() {
        // Arrange
        let value = 1099
        let store = StoreOf<IncrementReducer>(state: .init(value: value),
                                              reducer: IncrementReducer())

        // Act
        store.submit(.increment)

        // Assert
        XCTAssertEqual(try awaitPublisher(store.$state.dropFirst()),
                       .init(value: value + 1))
    }

    func testSendWithScope() {
        // Arrange
        let value = 1099
        let store = StoreOf<MainReducer>(state: .init(increment: .init(value: value)),
                                         reducer: MainReducer())
        let scopedStore = store.scope(mapState: \.increment,
                                      mapAction: MainReducer.Action.increment)

        // Act
        scopedStore.submit(.increment)

        // Assert
        XCTAssertEqual(try awaitPublisher(store.$state.dropFirst()),
                       .init(increment: .init(value: value + 1)))
        XCTAssertEqual(try awaitPublisher(scopedStore.$state.dropFirst()),
                       .init(value: value + 1))
    }

    func testSendWithScopeMediated() {
        // Arrange
        let value = 1099
        let store = StoreOf<MainReducer>(state: .init(increment: .init(value: value)),
                                         reducer: MainReducer())
        let scopedStore = store.scope(mapState: \.increment,
                                      mapAction: MainReducer.Action.increment)

        // Act
        store.submit(.increment(.increment))

        // Assert
        XCTAssertEqual(try awaitPublisher(store.$state.dropFirst()),
                       .init(increment: .init(value: value + 1)))
        XCTAssertEqual(try awaitPublisher(scopedStore.$state.dropFirst()),
                       .init(value: value + 1))
    }
}
