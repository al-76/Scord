//
//  Scope.swift
//  Scord
//
//  Created by Vyacheslav Konopkin on 30.12.2022.
//

public struct Scope<State, Action, ScopedReducer: Reducer>: Reducer {
    private let statePath: WritableKeyPath<State, ScopedReducer.State>
    private let mapAction: (Action) -> ScopedReducer.Action?
    private let reducer: ScopedReducer

    public init(state statePath: WritableKeyPath<State, ScopedReducer.State>,
                action mapAction: @escaping (Action) -> ScopedReducer.Action?,
                reducer: ScopedReducer) {
        self.statePath = statePath
        self.mapAction = mapAction
        self.reducer = reducer
    }

    public func reduce(state: inout State, action: Action) {
        guard let scopedAction = mapAction(action) else { return }
        reducer.reduce(state: &state[keyPath: statePath],
                       action: scopedAction)
    }
}

public struct ScopeOptional<State, Action, ScopedReducer: Reducer>: Reducer {
    private let statePath: WritableKeyPath<State, ScopedReducer.State?>
    private let mapAction: (Action) -> ScopedReducer.Action?
    private let reducer: ScopedReducer

    public init(state statePath: WritableKeyPath<State, ScopedReducer.State?>,
                action mapAction: @escaping (Action) -> ScopedReducer.Action?,
                reducer: ScopedReducer) {
        self.statePath = statePath
        self.mapAction = mapAction
        self.reducer = reducer
    }

    public func reduce(state: inout State, action: Action) {
        guard let scopedAction = mapAction(action),
              state[keyPath: statePath] != nil else { return }
        reducer.reduce(state: &state[keyPath: statePath]!,
                       action: scopedAction)
    }
}

public struct ScopeId<State, Action, ScopedReducer: Reducer>: Reducer where ScopedReducer.State: Identifiable {
    private let statePath: WritableKeyPath<State, IdDictionary<ScopedReducer.State>>
    private let mapAction: (Action) -> (ScopedReducer.State.ID, ScopedReducer.Action)?
    private let reducer: ScopedReducer

    public init(state statePath: WritableKeyPath<State, IdDictionary<ScopedReducer.State>>,
                action mapAction: @escaping (Action) -> (ScopedReducer.State.ID, ScopedReducer.Action)?,
                reducer: ScopedReducer) {
        self.statePath = statePath
        self.mapAction = mapAction
        self.reducer = reducer
    }

    public func reduce(state: inout State, action: Action) {
        guard let (id, scopedAction) = mapAction(action) else { return }
        reducer.reduce(state: &state[keyPath: statePath][id]!,
                       action: scopedAction)
    }
}
