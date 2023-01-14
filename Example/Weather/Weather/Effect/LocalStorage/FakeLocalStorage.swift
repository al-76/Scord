//
//  FakeLocalStorage.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 01.01.2023.
//

import Combine

final class FakeLocalStorage: LocalStorage {
    var saveAnswer = Just(())
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    var loadAnswer = Just([Location].stub)
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    var loadCountCall = 0

    func save(item: Location) -> AnyPublisher<Void, Error> {
        saveAnswer
    }

    func load() -> AnyPublisher<[Location], Error> {
        defer {
            loadCountCall += 1
        }
        return loadAnswer
    }
}
