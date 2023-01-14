//
//  ListWeatherReducer.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 04.01.2023.
//

import Foundation
import Combine
import Scord

struct ListWeatherReducer: Reducer {
    struct State: Equatable {
        var locations: [Location] = []
        var isLoading = false
        var error: StateError?

        var weather: WeatherReducer.State = .init()
    }

    enum Action {
        case fetchLocations(String)
        case fetchLocationsResult(Result<[Location], Error>)

        case addLocation(Location)
        case addLocationResult(Result<Location, Error>)

        case weatherAction(WeatherReducer.Action)

        static func getWeatherAction(action: Action) -> WeatherReducer.Action? {
            guard case let .weatherAction(action) = action else {
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
        Scope(state: \.weather,
              action: Action.getWeatherAction,
              reducer: WeatherReducer())

        Reduce { state, action in
            switch action {
            case .fetchLocations:
                state.isLoading = true
                state.error = nil

            case .fetchLocationsResult(let result):
                state.isLoading = false
                state.locations = result.getResult() ?? []
                state.error = StateError(result.getFailure())

            case .addLocation:
                state.error = nil

            case .addLocationResult(let result):
                if let location = result.getResult() {
                    let id = uuidProvider.uuid()
                    state.weather.weatherItems[id] = FetchWeatherReducer.State(id: id, location: location)
                }
                state.error = StateError(result.getFailure())

            default:
                break
            }
        }
    }
}
