//
//  Dependency+App.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 11.01.2023.
//

import Scord

extension Dependency {
    private static let store = StoreOf<AppReducer>(state: .init(),
                                               reducer: AppReducer(uuidProvider: DefaultUUIDProvider()))
                           .applyMiddlewares(middlewares: Dependency.pagerWeatherMiddlewares(),
                                             state: \.pagerWeather,
                                             action: AppReducer.Action.getPagerWeatherAction(action:),
                                             scopeAction: AppReducer.Action.pagerWeatherAction)
                           .applyMiddlewares(middlewares: Dependency.listWeatherMiddleware(),
                                             state: \.listWeather,
                                             action: AppReducer.Action.getListWeatherAction(action:),
                                             scopeAction: AppReducer.Action.listWeatherAction)

    static func appStore() -> StoreOf<AppReducer> {
        store
    }
}
