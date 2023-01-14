//
//  ListWeatherRowView.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 05.01.2023.
//

import Scord
import SwiftUI

struct ListWeatherRowView: View {
    @StateObject var store: StoreOf<FetchWeatherReducer>

    var body: some View {
        HStack {
            Text(store.state.location.formatted())
            Spacer()
            VStack(alignment: .leading) {
                if let weather = store.state.weather {
                    weatherView(weather)
                } else if store.state.isLoading {
                    ProgressView()
                }
            }
        }
        .onAppear {
            store.submit(.fetchWeather)
        }
    }

    @ViewBuilder
    private func weatherView(_ weather: Weather) -> some View {
        HStack {
            Image(systemName: weather.current.weathercode.sfSymbol())
                .foregroundStyle(.gray, .blue)
            Text(weather.current.temperature.temperature())
        }
        HStack {
            Image(systemName: "wind")
                .foregroundColor(.blue)
            Text(weather.current.windspeed.speed())
        }
    }
}

struct ListWeatherRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListWeatherRowView(store: StoreOf<FetchWeatherReducer>(
            state: .init(id: UUID(), location: .stub),
            reducer: FetchWeatherReducer(),
            middlewares: [
                FetchWeatherMiddleware(client: FakeWeatherClient())
            ]
        ))
    }
}
