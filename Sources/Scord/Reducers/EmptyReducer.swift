//
//  EmptyReducer.swift
//  
//
//  Created by Vyacheslav Konopkin on 11.01.2023.
//

public struct EmptyReducer<State: Equatable, Action>: Reducer {
    public init() {}

    public func reduce(state: inout State, action: Action) {
    }
}
