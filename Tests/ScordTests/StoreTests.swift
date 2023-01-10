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
        var increment: IncrementReducer.State

        var rows: IdDictionary<IncrementReducer.State> = [:]
    }

    enum Action {
        case increment(IncrementReducer.Action)
        case incrementId(id: IncrementReducer.State.ID, action: IncrementReducer.Action)

        static func getIncrementAction(action: Action) -> IncrementReducer.Action? {
            guard case .increment(let action) = action else { return nil }
            return action
        }

        static func getIncrementActionId(action: Action) -> (IncrementReducer.State.ID,
                                                             IncrementReducer.Action)? {
            guard case let .incrementId(id, action) = action else { return nil }
            return (id, action)
        }
    }

    var children: some Reducer<State, Action> {
        Scope(state: \.increment,
              action: MainReducer.Action.getIncrementAction,
              reducer: IncrementReducer())

        ScopeId(state: \.rows,
                action: MainReducer.Action.getIncrementActionId,
                reducer: IncrementReducer())

        EmptyReducer()

        for _ in 0...2 {
            EmptyReducer()
        }

        Reduce { state, action in

        }
    }
}

struct IncrementReducer: Reducer {
    struct State: Equatable, Identifiable {
        var id: UUID
        var value: Int = 0
    }

    enum Action {
        case increment
        case incrementResult(Int)
    }

    func reduce(state: inout State, action: Action) {
        print("reduce \(action)")
        switch action {
        case .increment:
            break

        case .incrementResult(let value):
            state.value = value
        }
    }
}

struct IncrementMiddleware: Middleware {
    func effect(state: IncrementReducer.State,
                action: IncrementReducer.Action) -> Effect<IncrementReducer.Action> {
        guard case .increment = action else {
            return noEffect()
        }

        print("effect \(action)")

        return Future { [value = state.value] promise in
            promise(.success(.incrementResult(value + 1)))
        }
        .eraseToAnyPublisher()
    }
}

struct SomeMiddleware: Middleware {
    func effect(state: IncrementReducer.State,
                action: IncrementReducer.Action) -> Effect<IncrementReducer.Action> {
        noEffect()
    }
}

final class StoreTests: XCTestCase {
    private var middlewares: [(IncrementReducer.State, IncrementReducer.Action) -> Effect<IncrementReducer.Action>] = [
        { IncrementMiddleware().effect(state: $0, action: $1) },
        { SomeMiddleware().effect(state: $0, action: $1) }
    ]

    func testSubmit() {
        // Arrange
        let id = UUID()
        let value = 1099
        let store = TestStoreOf<IncrementReducer>(state: .init(id: id, value: value),
                                                reducer: IncrementReducer().reduce(state:action:),
                                                middlewares: middlewares,
                                                scheduler: ImmediateScheduler.shared)

        // Act
        store.submit(.increment)

        // Assert
        XCTAssertEqual(store.state, .init(id: id, value: value + 1))
    }

    func testSubmitWithScope() {
        // Arrange
        let id = UUID()
        let value = 1099
        let store = TestStoreOf<MainReducer>(state: .init(increment: .init(id: id, value: value)),
                                             reducer: MainReducer())
            .applyMiddlewares(middlewares: middlewares,
                              state: \.increment,
                              action: MainReducer.Action.getIncrementAction,
                              scopeAction: MainReducer.Action.increment)
        let scopedStore = store.scope(state: \.increment,
                                      scopeAction: MainReducer.Action.increment)

        // Act
        scopedStore.submit(.increment)

        // Assert
        XCTAssertEqual(scopedStore.state, .init(id: id, value: value + 1))
        XCTAssertEqual(scopedStore.state, store.state.increment)
    }

    func testSubmitWithScopeMediated() {
        // Arrange
        let id = UUID()
        let value = 1099
        let store = TestStoreOf<MainReducer>(state: .init(increment: .init(id: id, value: value)),
                                             reducer: MainReducer())
            .applyMiddlewares(middlewares: middlewares,
                              state: \.increment,
                              action: MainReducer.Action.getIncrementAction,
                              scopeAction: MainReducer.Action.increment)
        let scopedStore = store.scope(state: \.increment,
                                      scopeAction: MainReducer.Action.increment)

        // Act
        store.submit(.increment(.increment))

        // Assert
        XCTAssertEqual(scopedStore.state, .init(id: id, value: value + 1))
        XCTAssertEqual(scopedStore.state, store.state.increment)
    }

    func testSubmitWithRows() {
        // Arrange
        let ids = [UUID(), UUID(), UUID()]
        let value = 1099
        let store = TestStoreOf<MainReducer>(state: .init(increment: .init(id: UUID()),
                                                          rows: ids.reduce(into: [:]) { $0[$1] = .init(id: $1, value: value) }),
                                             reducer: MainReducer())
            .applyMiddlewaresId(middlewares: middlewares,
                                state: \.rows,
                                action: MainReducer.Action.getIncrementActionId,
                                scopeAction: MainReducer.Action.incrementId(id:action:))
        var scopedStores = [TestStoreOf<IncrementReducer>]()
        ids.forEach { id in
            scopedStores.append(store.scope(id: id,
                                            state: \.rows,
                                            scopeAction: { MainReducer.Action.incrementId(id: id, action: $0) }))
        }

        // Act
        scopedStores.forEach { $0.submit(.increment) }

        // Assert
        ids.indices.forEach {
            XCTAssertEqual(scopedStores[$0].state, .init(id: ids[$0], value: value + 1))
            XCTAssertEqual(scopedStores[$0].state, store.state.rows[ids[$0]])
        }
    }
}
