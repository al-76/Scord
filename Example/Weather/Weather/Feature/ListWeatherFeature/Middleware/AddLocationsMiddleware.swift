//
//  AddLocationsMiddleware.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 06.01.2023.
//

import Combine
import Scord

struct AddLocationsMiddleware: Middleware {
    typealias State = ListWeatherReducer.State
    typealias Action = ListWeatherReducer.Action

    private let storage: any LocalStorage<Location>

    init(storage: some LocalStorage<Location>) {
        self.storage = storage
    }

    func effect(state: State, action: Action) -> Effect<Action> {
        guard case .addLocation(let location) = action else {
            return noEffect()
        }

        return storage
            .save(item: location)
            .map { .addLocationResult(.success(location)) }
            .catch { Just(.addLocationResult(.failure($0))) }
            .eraseToAnyPublisher()
    }
}
