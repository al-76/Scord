//
//  StateError.swift
//  Scord
//
//  Created by Vyacheslav Konopkin on 27.12.2022.
//

import Foundation

public struct StateError: Equatable {
    let error: Error

    public static func ==(lhs: StateError, rhs: StateError) -> Bool {
        type(of: lhs.error) == type(of: rhs.error) &&
        lhs.error.localizedDescription == rhs.error.localizedDescription
    }

    public func description() -> String {
        error.localizedDescription
    }
}
