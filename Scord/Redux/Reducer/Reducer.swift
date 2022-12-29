//
//  Reducer.swift
//  Scord
//
//  Created by Vyacheslav Konopkin on 27.12.2022.
//

import Combine

typealias Effect<Action> = AnyPublisher<Action, Never>

protocol Reducer<State, Action> {
    associatedtype State
    associatedtype Action
    associatedtype Children

    @ReducerBuilder<State, Action>
    var children: Children { get }

    func reduce(state: inout State, action: Action) -> Effect<Action>
}

typealias ReducerOf<T: Reducer> = Reducer<T.State, T.Action>

extension Reducer where Children == Never {
    var children: Children {
        fatalError("No children")
    }
}

extension Reducer where Children: Reducer, Children.State == State, Children.Action == Action {
    func reduce(state: inout State, action: Action) -> Effect<Action> {
        children.reduce(state: &state, action: action)
    }
}

struct EmptyReducer<State, Action>: Reducer {
    func reduce(state: inout State, action: Action) -> Effect<Action> {
        noEffect()
    }
}

struct ReducerContainer<State, Action, ReducerType: Reducer>: Reducer {
    let reducer: ReducerType

    func reduce(state: inout State, action: Action) -> Effect<Action> {
        noEffect()
    }
}

func noEffect<Action>() -> Effect<Action> {
    Empty().eraseToAnyPublisher()
}
