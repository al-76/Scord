//
//  WeatherReducer.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 01.01.2023.
//

import Combine
import Foundation
import Scord

struct WeatherReducer: Reducer {
    typealias WeatherItems = IdDictionary<FetchWeatherReducer.State>

    struct State: Equatable {
        var error: StateError?

        var weather: FetchWeatherReducer.State?
        var weatherItems: WeatherItems = [:]
    }

    enum Action {
        case initWeather(UUID, Location)

        case loadWeatherItems
        case loadWeatherItemsResult(Result<WeatherItems, Error>)

        case weatherItemAction(action: FetchWeatherReducer.Action)
        case weatherItemActionId(FetchWeatherReducer.State.ID, action: FetchWeatherReducer.Action)

        static func getWeatherItemAction(action: Action) -> FetchWeatherReducer.Action? {
            guard case let .weatherItemAction(action: action) = action else { return nil }
            return action
        }

        static func getWeatherItemActionId(action: Action) -> (FetchWeatherReducer.State.ID,
                                                               FetchWeatherReducer.Action)? {
            guard case let .weatherItemActionId(id, action) = action else { return nil }
            return (id, action)
        }
    }

    var children: some Reducer<State, Action> {
        ScopeOptional(state: \.weather,
                      action: Action.getWeatherItemAction,
                      reducer: FetchWeatherReducer())

        ScopeId(state: \.weatherItems,
                action: Action.getWeatherItemActionId,
                reducer: FetchWeatherReducer())

        Reduce { state, action in
            switch action {
            case let .initWeather(id, location):
                state.weather = .init(id: id, location: location)

            case .loadWeatherItems:
                state.error = nil

            case .loadWeatherItemsResult(let result):
                state.weatherItems = result.getResult() ?? [:]
                state.error = StateError(result.getFailure())

            default:
                break
            }
        }
    }
}
