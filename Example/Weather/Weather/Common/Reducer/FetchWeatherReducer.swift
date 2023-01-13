//
//  FetchWeatherReducer.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 12.01.2023.
//

import Foundation
import Scord

struct FetchWeatherReducer: Reducer {
    struct State: Equatable, Identifiable {
        var id: UUID
        var location: Location
        var weather: Weather?
        var isLoading = false
        var error: StateError?
    }

    enum Action {
        case fetchWeather
        case fetchWeatherProcess
        case fetchWeatherResult(Result<Weather, Error>)
    }

    func reduce(state: inout State, action: Action) {
        switch action {
        case .fetchWeather:
            state.isLoading = true
            state.error = nil

        case .fetchWeatherProcess:
            break

        case .fetchWeatherResult(let result):
            state.isLoading = false
            state.weather = result.getResult()
            state.error = StateError(result.getFailure())
        }
    }
}
