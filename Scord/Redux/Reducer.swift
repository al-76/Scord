//
//  Reducer.swift
//  Scord
//
//  Created by Vyacheslav Konopkin on 27.12.2022.
//

import Combine

typealias Effect<Action> = AnyPublisher<Action, Never>

protocol Reducer {
    associatedtype State
    associatedtype Action

    func reduce(state: inout State, action: Action) -> Effect<Action>
}

func noEffect<Action>() -> Effect<Action> {
    Empty().eraseToAnyPublisher()
}
