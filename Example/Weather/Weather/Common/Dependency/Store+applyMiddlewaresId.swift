//
//  Store+applyMiddlewaresId.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 13.01.2023.
//

import Scord

extension Store where Action == WeatherReducer.Action, State == WeatherReducer.State {
    func applyMiddlewares(client: WeatherClient = DefaultWeatherClient()) -> Self {
        applyMiddlewaresId(middlewares: [ FetchWeatherMiddleware(client: client) ],
                           state: \.weatherItems,
                           action: WeatherReducer.Action.getWeatherItemActionId,
                           scopeAction: { WeatherReducer.Action.weatherItemActionId($0, action: $1) })
        .applyMiddlewares(middlewares: [ FetchWeatherMiddleware(client: client) ],
                          state: \.weather,
                          action: WeatherReducer.Action.getWeatherItemAction,
                          scopeAction: WeatherReducer.Action.weatherItemAction)
    }
}
