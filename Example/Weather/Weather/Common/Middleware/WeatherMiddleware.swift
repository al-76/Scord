//
//  WeatherMiddleware.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 12.01.2023.
//

import Combine
import Scord

struct WeatherMiddleware: Middleware {
    typealias State = WeatherReducer.State
    typealias Action = WeatherReducer.Action

    private let storage: any LocalStorage<Location>
    private let uuidProvider: UUIDProvider

    init(storage: some LocalStorage<Location>,
         uuidProvider: UUIDProvider) {
        self.storage = storage
        self.uuidProvider = uuidProvider
    }

    func effect(state: State, action: Action) -> Effect<Action> {
        guard case .loadWeatherItems = action,
              state.weatherItems.isEmpty else { return noEffect() }

        return storage
            .load()
            .map { locations in
                locations
                    .reduce(into: ListWeatherReducer.WeatherItems()) {
                        let id = uuidProvider.uuid()
                        return $0[id] = .init(id: id, location: $1)
                    }
            }
            .map { .loadWeatherItemsResult(.success($0)) }
            .catch { Just(.loadWeatherItemsResult(.failure($0))) }
            .eraseToAnyPublisher()
    }
}
