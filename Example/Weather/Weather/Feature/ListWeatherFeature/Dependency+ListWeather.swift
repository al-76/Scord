//
//  Dependency+ListWeather.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 11.01.2023.
//

import Scord

extension Dependency {
    private static let middlewares: [any MiddlewareOf<ListWeatherReducer>] = [
        AddLocationsMiddleware(storage: DefaultLocalStorage(name: "locations")),
        FetchLocationsMiddleware(client: DefaultLocationClient())
    ]

    static func listWeatherMiddleware() -> [any MiddlewareOf<ListWeatherReducer>] {
        middlewares
    }
}

extension Store where Action == ListWeatherReducer.Action, State == ListWeatherReducer.State {
    func applyMiddlewares(storage: some LocalStorage<Location> = DefaultLocalStorage(name: "locations"),
                          uuidProvider: UUIDProvider = DefaultUUIDProvider()) -> Self {
        applyMiddlewares(middlewares: [ WeatherMiddleware(storage: storage,
                                                          uuidProvider: uuidProvider) ],
                         state: \.weather,
                         action: ListWeatherReducer.Action.getWeatherAction,
                         scopeAction: ListWeatherReducer.Action.weatherAction)
    }
}
