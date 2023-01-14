//
//  DefaultWeatherClient.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 01.01.2023.
//

import Combine
import Foundation

final class DefaultWeatherClient: WeatherClient {
    func fetchWeather(by location: Location) -> AnyPublisher<Weather, Error> {
        URLSession.shared
            .dataTaskPublisher(for: getUrl(location))
            .map { $0.data }
            .decode(type: Weather.self, decoder: getJSONDecoder())
            .eraseToAnyPublisher()
    }

    private func getUrl(_ location: Location) -> URL {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: "\(location.latitude)"),
            URLQueryItem(name: "longitude", value: "\(location.longitude)"),
            URLQueryItem(name: "current_weather", value: "true"),
            URLQueryItem(name: "daily", value: "temperature_2m_min,temperature_2m_max,weathercode"),
            URLQueryItem(name: "timezone", value: TimeZone.autoupdatingCurrent.identifier)
        ]
        return components.url!
    }

    private func getJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            Weather.parseDate(from: try decoder
                .singleValueContainer()
                .decode(String.self))
        }
        return decoder
    }
}
