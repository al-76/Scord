//
//  ReducerCollection.swift
//  Scord
//
//  Created by Vyacheslav Konopkin on 30.12.2022.
//

import Combine

public struct ReducerCollection<Element: Reducer>: Reducer {
    private let elements: [Element]

    public init(elements: [Element]) {
        self.elements = elements
    }

    public func reduce(state: inout Element.State,
                       action: Element.Action) {
        elements
            .forEach { $0.reduce(state: &state, action: action) }
    }
}
