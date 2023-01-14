//
//  FetchLocationsMiddleware.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 06.01.2023.
//

import Combine
import Scord

struct FetchLocationsMiddleware: Middleware {
    typealias State = ListWeatherReducer.State
    typealias Action = ListWeatherReducer.Action

    private let client: LocationClient

    init(client: LocationClient) {
        self.client = client
    }

    func effect(state: State, action: Action) -> Effect<Action> {
        guard case .fetchLocations(let query) = action else {
            return noEffect()
        }

        if query.count < 2 {
            return Just(.fetchLocationsResult(.success([])))
                .eraseToAnyPublisher()
        }

        return client
            .fetchLocation(by: query)
            .map { .fetchLocationsResult(.success($0)) }
            .catch { Just(.fetchLocationsResult(.failure($0))) }
            .eraseToAnyPublisher()
    }
}
