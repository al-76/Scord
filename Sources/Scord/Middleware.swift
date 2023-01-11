//
//  Middleware.swift
//  Scord
//
//  Created by Vyacheslav Konopkin on 30.12.2022.
//

import Combine

public protocol Middleware<State, Action> {
    associatedtype State
    associatedtype Action

    func effect(state: State, action: Action) -> Effect<Action>
}

public typealias MiddlewareOf<T: Reducer> = Middleware<T.State, T.Action>

public typealias Effect<Action> = AnyPublisher<Action, Never>

public func noEffect<Action>() -> Effect<Action> {
    Empty().eraseToAnyPublisher()
}
