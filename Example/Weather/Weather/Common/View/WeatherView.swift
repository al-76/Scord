//
//  WeatherView.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 31.12.2022.
//

import Scord
import SwiftUI

struct WeatherView: View {
    @StateObject var store: StoreOf<FetchWeatherReducer>

    var body: some View {
        VStack {
            if let error = store.state.error {
                Text("Error: \(error.description)")
            }

            if let weather = store.state.weather {
                Text(store.state.location.formatted())
                    .font(.headline)

                weatherView(weather)
            }
        }
        .overlay {
            if store.state.isLoading {
                ProgressView()
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
            Text("\(weather.current.temperature.temperature())")
        }

        HStack {
            Image(systemName: "wind")
                .foregroundColor(.blue)
            Text("\(weather.current.windspeed.speed())")
        }

        ForEach(weather.daily) { daily in
            VStack {
                Divider()
                Text(daily.time.formatted(date: .complete,
                                          time: .omitted))
                    .font(.footnote)
                HStack {
                    Image(systemName: daily.weathercode.sfSymbol())
                        .foregroundStyle(.gray, .blue)
                    Text(daily.temperature.min.temperature())
                    Text("...")
                    Text(daily.temperature.max.temperature())
                }
            }
        }
    }
}

extension Location {
    func formatted() -> String {
        "\(name), \(country)"
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView(store: StoreOf<FetchWeatherReducer>(
            state: .init(id: UUID(),
                         location: .stub),
            reducer: FetchWeatherReducer(),
            middlewares: [
                FetchWeatherMiddleware(client: FakeWeatherClient())
            ]
        ))
    }
}
