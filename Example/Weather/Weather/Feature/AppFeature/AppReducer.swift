//
//  AppReducer.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 11.01.2023.
//

import Scord

struct AppReducer: Reducer {
    struct State: Equatable {
        var pagerWeather: WeatherReducer.State = .init()
        var listWeather: ListWeatherReducer.State = .init()
    }

    enum Action {
        case pagerWeatherAction(WeatherReducer.Action)
        case listWeatherAction(ListWeatherReducer.Action)

        static func getPagerWeatherAction(action: Action) -> WeatherReducer.Action? {
            guard case .pagerWeatherAction(let action) = action else {
                return nil
            }
            return action
        }

        static func getListWeatherAction(action: Action) -> ListWeatherReducer.Action? {
            guard case .listWeatherAction(let action) = action else {
                return nil
            }
            return action
        }
    }

    private let uuidProvider: UUIDProvider

    init(uuidProvider: UUIDProvider) {
        self.uuidProvider = uuidProvider
    }

    var children: some Reducer<State, Action> {
        Scope(state: \.pagerWeather,
              action: Action.getPagerWeatherAction,
              reducer: WeatherReducer())

        Scope(state: \.listWeather,
              action: Action.getListWeatherAction,
              reducer: ListWeatherReducer(uuidProvider: uuidProvider))
    }
}
