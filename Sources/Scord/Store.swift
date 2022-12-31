//
//  Store.swift
//  Scord
//
//  Created by Vyacheslav Konopkin on 27.12.2022.
//

import Combine
import Foundation

public typealias StoreOf<T: Reducer> = Store<T.State, T.Action>

public extension Store {
    convenience init<T: Reducer>(state: T.State,
                                 reducer: T)
    where T.State == State, T.Action == Action {
        self.init(state: state,
                  reducer: reducer.reduce)
    }
}

public extension Store {
    @available(iOS 16.0.0, *)
    convenience init<T: Reducer>(state: T.State,
                                 reducer: T,
                                 middlewares: [any Middleware<T.State, T.Action>] = [])
    where T.State == State, T.Action == Action {
        self.init(state: state,
                  reducer: reducer.reduce,
                  middlewares: middlewares.map { $0.callAsFunction(state:action:) })
    }
}

final public class Store<State, Action>: ObservableObject {
    public typealias OnReduce<State, Action> = (inout State, Action) -> Void
    public typealias OnMiddleware<State, Action> = (State, Action) -> Effect<Action>

    @Published private(set) var state: State

    private let reducer: OnReduce<State, Action>
    private var middlewares: [OnMiddleware<State, Action>]
    private var cancellable = Set<AnyCancellable>()

    init(state: State,
         reducer: @escaping OnReduce<State, Action>,
         middlewares: [OnMiddleware<State, Action>] = []) {
        self.state = state
        self.reducer = reducer
        self.middlewares = middlewares
    }

    public func submit(_ action: Action) {
        reducer(&state, action)

        Publishers
            .MergeMany(middlewares.map { $0(state, action) })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in self?.submit($0) })
            .store(in: &cancellable)
    }

    public func scope<ScopeState,
                      ScopeAction>(mapState: @escaping (State) -> ScopeState,
                                   mapAction: @escaping (ScopeAction) -> Action) -> Store<ScopeState, ScopeAction> {
        let store = Store<ScopeState,
                          ScopeAction>(state: mapState(state)) { [weak self] state, action in
                              self?.submit(mapAction(action))
                          }

        $state
            .map(mapState)
            .receive(on: DispatchQueue.main)
            .assign(to: &store.$state)

        return store
    }

    @available(iOS 16.0.0, *)
    public func applyMiddlewares<ScopeState,
                                 ScopeAction>(middlewares: [any Middleware<ScopeState, ScopeAction>],
                                              mapState: @escaping (State) -> ScopeState,
                                              mapAction: @escaping (Action) -> ScopeAction?,
                                              mapScopeAction: @escaping (ScopeAction) -> Action) {
        applyMiddlewares(middlewares: middlewares.map { $0.callAsFunction(state:action:) },
                         mapState: mapState,
                         mapAction: mapAction,
                         mapScopeAction: mapScopeAction)
    }

    public func applyMiddlewares<ScopeState,
                                 ScopeAction>(middlewares: [OnMiddleware<ScopeState, ScopeAction>],
                                              mapState: @escaping (State) -> ScopeState,
                                              mapAction: @escaping (Action) -> ScopeAction?,
                                              mapScopeAction: @escaping (ScopeAction) -> Action) {
        let mapMiddleware: (OnMiddleware<ScopeState, ScopeAction>,
                            State,
                            Action) -> Effect<Action> = {
            guard let action = mapAction($2) else { return noEffect() }
            return $0(mapState($1), action)
                .map { mapScopeAction($0) }
                .eraseToAnyPublisher()
        }

        self.middlewares += middlewares.map {
            bind(mapMiddleware)($0)
        }
    }

    private func bind<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B, C) -> D {
        { a in { b, c in f(a, b, c) } }
    }
}
