//
//  StoreTests.swift
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

        static func getIncrementAction(action: Action) -> IncrementReducer.Action? {
            guard case .increment(let action) = action else { return nil }
            return action
        }
    }

    var children: some Reducer<State, Action> {
        Scope(statePath: \.increment,
              mapAction: MainReducer.Action.getIncrementAction,
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

    func reduce(state: inout State, action: Action) {
        switch action {
        case .incrementResult(let value):
            state.value = value

        default:
            break
        }
    }
}

struct IncrementMiddleware: Middleware {
    func callAsFunction(state: IncrementReducer.State,
                        action: IncrementReducer.Action) -> Effect<IncrementReducer.Action> {
        guard case .increment = action else {
            return noEffect()
        }

        return Future { [value = state.value] promise in
            promise(.success(.incrementResult(value + 1)))
        }
        .eraseToAnyPublisher()
    }
}

struct SomeMiddleware: Middleware {
    func callAsFunction(state: IncrementReducer.State,
                        action: IncrementReducer.Action) -> Effect<IncrementReducer.Action> {
        noEffect()
    }
}

final class StoreTests: XCTestCase {
    private var middlewares: [(IncrementReducer.State, IncrementReducer.Action) -> Effect<IncrementReducer.Action>] = [
        { IncrementMiddleware()(state: $0, action: $1) },
        { SomeMiddleware()(state: $0, action: $1) }
    ]

    func testSubmit() {
        // Arrange
        let value = 1099
        let store = Store<IncrementReducer.State,
                          IncrementReducer.Action>(state: .init(value: value),
                                                   reducer: IncrementReducer().reduce(state:action:),
                                                   middlewares: middlewares)

        // Act
        store.submit(.increment)

        // Assert
        XCTAssertEqual(try awaitPublisher(store.$state.dropFirst()),
                       .init(value: value + 1))
    }

    func testSubmitWithScope() {
        // Arrange
        let value = 1099
        let store = StoreOf<MainReducer>(state: .init(increment: .init(value: value)),
                                       reducer: MainReducer())
        store.applyMiddlewares(middlewares: middlewares,
                               mapState: \.increment,
                               mapAction: MainReducer.Action.getIncrementAction,
                               mapScopeAction: MainReducer.Action.increment)
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

    func testSubmitWithScopeMediated() {
        // Arrange
        let value = 1099
        let store = StoreOf<MainReducer>(state: .init(increment: .init(value: value)),
                                              reducer: MainReducer())
        store.applyMiddlewares(middlewares: middlewares,
                               mapState: \.increment,
                               mapAction: MainReducer.Action.getIncrementAction,
                               mapScopeAction: MainReducer.Action.increment)
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
