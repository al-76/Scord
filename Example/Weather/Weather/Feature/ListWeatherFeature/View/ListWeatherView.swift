//
//  ListWeatherView.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 13.01.2023.
//

import Scord
import SwiftUI

struct ListWeatherView: View {
    @StateObject var store: StoreOf<ListWeatherReducer>

    var body: some View {
        ListWeatherContainerView(
            store: store
                .scope(state: \.weather,
                               scopeAction: ListWeatherReducer.Action.weatherAction)
                .applyMiddlewares(),
            onAddLocation: { store.submit(.addLocation($0)) },
            onSearchLocation: { store.submit(.fetchLocations($0)) },
            onFoundLocations: { store.state.locations }
        )
    }
}

struct ListWeatherView_Previews: PreviewProvider {
    static var previews: some View {
        ListWeatherView(store: StoreOf<ListWeatherReducer>(
            state: .init(),
            reducer: ListWeatherReducer(uuidProvider: DefaultUUIDProvider())
        ).applyMiddlewares(storage: FakeLocalStorage()))
    }
}
