//
//  Dependency+PagerWeather.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 11.01.2023.
//

import Scord

extension Dependency {
    private static let middlewares: [any MiddlewareOf<WeatherReducer>] = [
        WeatherMiddleware(storage: DefaultLocalStorage(name: "locations"),
                          uuidProvider: DefaultUUIDProvider())
    ]

    static func pagerWeatherMiddlewares() -> [any MiddlewareOf<WeatherReducer>] {
        middlewares
    }
}
