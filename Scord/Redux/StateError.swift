//
//  StateError.swift
//  Scord
//
//  Created by Vyacheslav Konopkin on 27.12.2022.
//

import Foundation

struct StateError: Equatable {
    let error: Error

    static func ==(lhs: StateError, rhs: StateError) -> Bool {
        type(of: lhs.error) == type(of: rhs.error) &&
        lhs.error.localizedDescription == rhs.error.localizedDescription
    }

    func description() -> String {
        error.localizedDescription
    }
}
