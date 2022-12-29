//
//  Scope.swift
//  Scord
//
//  Created by Vyacheslav Konopkin on 30.12.2022.
//

struct Scope<State, Action, ScopedReducer: Reducer>: Reducer {
    let statePath: WritableKeyPath<State, ScopedReducer.State>
    let mapAction: (Action) -> ScopedReducer.Action?
    let mapScopedAction: (ScopedReducer.Action) -> Action
    let reducer: ScopedReducer

    func reduce(state: inout State, action: Action) -> Effect<Action> {
        guard let scopedAction = mapAction(action) else {
            return noEffect()
        }

        return reducer.reduce(state: &state[keyPath: statePath],
                              action: scopedAction)
        .map { mapScopedAction($0) }
        .eraseToAnyPublisher()
    }
}
