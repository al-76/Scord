//
//  ReducerCollection.swift
//  Scord
//
//  Created by Vyacheslav Konopkin on 30.12.2022.
//

import Combine

struct ReducerCollection<Element: Reducer>: Reducer {
    var elements: [Element]

    func reduce(state: inout Element.State,
                action: Element.Action) -> Effect<Element.Action> {
        Publishers.MergeMany(
            elements
                .map { $0.reduce(state: &state, action: action) }
        ).eraseToAnyPublisher()
    }
}
