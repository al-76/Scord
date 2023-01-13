//
//  Reduce.swift
//  
//
//  Created by Vyacheslav Konopkin on 11.01.2023.
//

public struct Reduce<State: Equatable, Action>: Reducer {
    private let onReduce: (inout State, Action) -> Void

    public init(onReduce: @escaping (inout State, Action) -> Void) {
        self.onReduce = onReduce
    }

    public func reduce(state: inout State, action: Action) {
        onReduce(&state, action)
    }
}
