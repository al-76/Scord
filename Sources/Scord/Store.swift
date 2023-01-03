//
//  Store.swift
//  Scord
//
//  Created by Vyacheslav Konopkin on 27.12.2022.
//

import Combine
import Foundation

public typealias StoreOf<T: Reducer> = Store<T.State, T.Action, DispatchQueue>
public typealias TestStoreOf<T: Reducer> = Store<T.State, T.Action, ImmediateScheduler>

public extension Store where Scheduler == DispatchQueue {
    convenience init<T: Reducer>(state: T.State,
                                 reducer: T,
                                 scheduler: Scheduler = .main)
    where T.State == State, T.Action == Action {
        self.init(state: state,
                  reducer: reducer.reduce,
                  middlewares: [],
                  scheduler: scheduler)
    }
}

public extension Store where Scheduler == ImmediateScheduler {
    convenience init<T: Reducer>(state: T.State,
                                 reducer: T,
                                 scheduler: Scheduler = .shared)
    where T.State == State, T.Action == Action {
        self.init(state: state,
                  reducer: reducer.reduce,
                  middlewares: [],
                  scheduler: scheduler)
    }
}

public extension Store where Scheduler == DispatchQueue {
    @available(iOS 16.0.0, *)
    convenience init<T: Reducer>(state: T.State,
                                 reducer: T,
                                 middlewares: [any Middleware<T.State, T.Action>] = [],
                                 scheduler: Scheduler = .main)
    where T.State == State, T.Action == Action {
        self.init(state: state,
                  reducer: reducer.reduce,
                  middlewares: middlewares.map { $0.effect(state:action:) },
                  scheduler: scheduler)
    }
}

public extension Store where Scheduler == ImmediateScheduler {
    @available(iOS 16.0.0, *)
    convenience init<T: Reducer>(state: T.State,
                                 reducer: T,
                                 middlewares: [any Middleware<T.State, T.Action>] = [],
                                 scheduler: Scheduler = .shared)
    where T.State == State, T.Action == Action {
        self.init(state: state,
                  reducer: reducer.reduce,
                  middlewares: middlewares.map { $0.effect(state:action:) },
                  scheduler: scheduler)
    }
}

final public class Store<State, Action, Scheduler: Combine.Scheduler>: ObservableObject {
    public typealias OnReduce<State, Action> = (inout State, Action) -> Void
    public typealias OnMiddleware<State, Action> = (State, Action) -> Effect<Action>

    @Published public private(set) var state: State

    private let reducer: OnReduce<State, Action>
    private var middlewares: [OnMiddleware<State, Action>]
    private var cancellable = Set<AnyCancellable>()
    private let scheduler: Scheduler

    init(state: State,
         reducer: @escaping OnReduce<State, Action>,
         middlewares: [OnMiddleware<State, Action>] = [],
         scheduler: Scheduler = DispatchQueue.main) {
        self.state = state
        self.reducer = reducer
        self.middlewares = middlewares
        self.scheduler = scheduler
    }

    public func submit(_ action: Action) {
        Publishers
            .MergeMany(middlewares.map { $0(state, action) })
            .receive(on: scheduler)
            .sink(receiveValue: { [weak self] in self?.submit($0) })
            .store(in: &cancellable)

        reducer(&state, action)
    }

    public func scope<ScopeState,
                      ScopeAction>(mapState: @escaping (State) -> ScopeState,
                                   mapAction: @escaping (ScopeAction) -> Action) -> Store<ScopeState, ScopeAction, Scheduler> {
        let reduce: OnReduce<ScopeState, ScopeAction> = { [weak self] in
            guard let self else { return }
            self.submit(mapAction($1))
            $0 = mapState(self.state)
        }
        let store = Store<ScopeState,
                          ScopeAction,
                          Scheduler>(state: mapState(state),
                                     reducer: reduce,
                                     middlewares: [],
                                     scheduler: scheduler)

        $state
            .dropFirst()
            .map(mapState)
            .receive(on: scheduler)
            .assign(to: &store.$state)

        return store
    }

    @available(iOS 16.0.0, *)
    public func applyMiddlewares<ScopeState,
                                 ScopeAction>(middlewares: [any Middleware<ScopeState, ScopeAction>],
                                              mapState: @escaping (State) -> ScopeState,
                                              mapAction: @escaping (Action) -> ScopeAction?,
                                              mapScopeAction: @escaping (ScopeAction) -> Action) {
        applyMiddlewares(middlewares: middlewares.map { $0.effect(state:action:) },
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
