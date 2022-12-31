//
//  Middleware.swift
//  Scord
//
//  Created by Vyacheslav Konopkin on 30.12.2022.
//

import Combine

protocol Middleware<State, Action> {
    associatedtype State
    associatedtype Action

    func callAsFunction(state: State, action: Action) -> Effect<Action>
}

typealias Effect<Action> = AnyPublisher<Action, Never>

func noEffect<Action>() -> Effect<Action> {
    Empty().eraseToAnyPublisher()
}
