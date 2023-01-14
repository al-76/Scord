//
//  PagerWeatherView.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 31.12.2022.
//

import SwiftUI
import Scord

struct PagerWeatherView: View {
    @StateObject var store: StoreOf<WeatherReducer>

    let onNoLocation: () -> Void

    var body: some View {
        VStack {
            if let error = store.state.error {
                Text("Error: \(error.description)")
            }

            if store.state.weatherItems.values.isEmpty {
                Button("Please, add some location") {
                    onNoLocation()
                }
            } else {
                itemsView()
            }
        }
        .onAppear {
            store.submit(.loadWeatherItems)
        }
    }

    private func itemsView() -> some View {
        TabView {
            ForEach(store.state.weatherItems.values) { item in
                WeatherView(store: store.scope(id: item.id,
                                               state: \.weatherItems,
                                               scopeAction: {
                    WeatherReducer.Action.weatherItemActionId(item.id, action: $0)
                }))
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct PagerWeatherView_Previews: PreviewProvider {
    static var previews: some View {
        PagerWeatherView(store: StoreOf<WeatherReducer>(
            state: .init(),
            reducer: WeatherReducer(),
            middlewares: [
                WeatherMiddleware(storage: FakeLocalStorage(),
                                  uuidProvider: DefaultUUIDProvider())
            ]
        ).applyMiddlewares(client: FakeWeatherClient()),
                         onNoLocation: {})
    }
}
