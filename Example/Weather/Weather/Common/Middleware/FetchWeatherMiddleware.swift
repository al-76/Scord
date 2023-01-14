//
//  File.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 06.01.2023.
//

import Combine
import Foundation
import Scord

struct FetchWeatherMiddleware: Middleware {
    typealias State = FetchWeatherReducer.State
    typealias Action = FetchWeatherReducer.Action

    private let client: WeatherClient

    init(client: WeatherClient) {
        self.client = client
    }

    func effect(state: State, action: Action) -> Effect<Action> {
        switch action {
        case .fetchWeather:
            return Just(.fetchWeatherProcess)
                .eraseToAnyPublisher()

        case .fetchWeatherProcess:
            break

        default:
            return noEffect()
        }

        return client
            .fetchWeather(by: state.location)
            .map { .fetchWeatherResult(.success($0)) }
            .catch { Just(.fetchWeatherResult(.failure($0))) }
            .eraseToAnyPublisher()
    }
}
