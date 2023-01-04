//
//  ListWeather.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 04.01.2023.
//

import Combine
import Scord

struct ListWeatherReducer: Reducer {
    struct State: Equatable {
        var savedLocations: [Location] = []
        var foundLocations: [Location] = []
        var isLoading = false
        var error: StateError? = nil
    }

    enum Action {
        case loadLocations
        case loadLocationsResult(Result<[Location], Error>)

        case searchLocations(String)
        case searchLocationsResult(Result<[Location], Error>)

        case addLocation(Location)
        case addLocationResult(Result<Location, Error>)
    }

    func reduce(state: inout State, action: Action) {

    }
}
