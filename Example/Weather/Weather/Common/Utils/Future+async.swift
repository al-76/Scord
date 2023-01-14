//
//  Combine+async.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 01.01.2023.
//

import Combine

extension Future where Failure == Error {
    convenience init(asyncFunction: @escaping () async throws -> Output) {
        self.init({ promise in
            Task {
                do {
                    promise(.success(try await asyncFunction()))
                } catch let error {
                    promise(.failure(error))
                }
            }
        })
    }
}
