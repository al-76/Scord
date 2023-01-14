//
//  ListWeatherContainerView.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 31.12.2022.
//

import Scord
import SwiftUI

struct ListWeatherContainerView: View {
    @StateObject private var textDebouncer = TextDebouncer()
    @State private var selectedLocation: Location?
    @State private var isAddedLocation = false
    
    @StateObject var store: StoreOf<WeatherReducer>

    var onAddLocation: (Location) -> Void
    var onSearchLocation: (String) -> Void
    var onFoundLocations: () -> [Location]

    var body: some View {
        NavigationStack {
            if let error = store.state.error {
                Text("Error: \(error.description)")
            }
            List {
                ForEach(store.state.weatherItems.values) { item in
                    ListWeatherRowView(store: store.scope(
                        id: item.id,
                        state: \.weatherItems,
                        scopeAction: { WeatherReducer.Action
                            .weatherItemActionId(item.id, action: $0) }
                    ))
                    .onTapGesture {
                        selectedLocation = item.location
                        isAddedLocation = true
                    }
                }
            }
            .navigationTitle("Weather")
        }
        .searchable(text: $textDebouncer.input) {
            Group {
                ForEach(onFoundLocations()) { location in
                    Button(location.formatted()) {
                        selectedLocation = location
                        isAddedLocation = false
                    }
                }
            }
            .onChange(of: textDebouncer.output) {
                onSearchLocation($0)
            }
        }
        .onAppear {
            store.submit(.loadWeatherItems)
        }
        .onChange(of: selectedLocation) { location in
            guard let location else { return }
            store.submit(.initWeather(UUID(), location))
        }
        .sheet(item: $selectedLocation) {
            sheetView($0)
        }
    }

    private func sheetView(_ location: Location) -> some View {
        VStack(alignment: .trailing) {
            HStack {
                Spacer()
                Button("Add") {
                    if let location = selectedLocation {
                        onAddLocation(location)
                    }
                    selectedLocation = nil
                }
                .padding(8)
                .buttonStyle(.bordered)
                .isHidden(!isAddedLocation)
            }
            Spacer()
            if store.state.weather != nil {
                WeatherView(store: store
                    .scope(state: { $0.weather! },
                           scopeAction: WeatherReducer.Action.weatherItemAction))
            }
            Spacer()
        }
        .transition(.asymmetric(insertion: .scale, removal: .opacity))
        .onTapGesture {
            selectedLocation = nil
        }
    }
}

struct ListWeatherContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ListWeatherContainerView(store: StoreOf<WeatherReducer>(
            state: .init(),
            reducer: WeatherReducer(),
            middlewares: [
                WeatherMiddleware(storage: FakeLocalStorage(),
                                  uuidProvider: FakeUUIDProvider()),
            ]).applyMiddlewares(client: FakeWeatherClient()),
                        onAddLocation: { _ in },
                        onSearchLocation: { _ in },
                        onFoundLocations: { .stub })
    }
}
