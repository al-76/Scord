//
//  Store.swift
//  Scord
//
//  Created by Vyacheslav Konopkin on 27.12.2022.
//

import Combine
import Foundation

typealias StoreOf<ReducerType: Reducer> = Store<ReducerType.Action, ReducerType.State>

extension Store {
    convenience init<ReducerType: Reducer>(state: ReducerType.State,
                                           reducer: ReducerType) where Action == ReducerType.Action, State == ReducerType.State {
        self.init(state: state) {
            reducer.reduce(state: &$0, action: $1)
        }
    }
}

final class Store<Action, State>: ObservableObject {
    typealias OnReduce<State, Action> = (inout State, Action) -> Effect<Action>

    @Published private(set) var state: State

    private let reducer: OnReduce<State, Action>
    private var cancellable = Set<AnyCancellable>()

    init(state: State, reducer: @escaping OnReduce<State, Action>) {
        self.state = state
        self.reducer = reducer
    }

    func submit(_ action: Action) {
        reducer(&state, action)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in self?.submit($0) })
            .store(in: &cancellable)
    }

    func scope<ScopedReducer: Reducer>(onState: @escaping (State) -> ScopedReducer.State,
                                       onAction: @escaping (ScopedReducer.Action) -> Action,
                                       _ type: ScopedReducer.Type) -> Store<ScopedReducer.Action, ScopedReducer.State> {
        let store = Store<ScopedReducer.Action,
                          ScopedReducer.State>(state: onState(state)) { [weak self] state, action in
                              self?.submit(onAction(action))
                              return noEffect()
                          }

        $state
            .map(onState)
            .receive(on: DispatchQueue.main)
            .assign(to: &store.$state)

        return store
    }
}
