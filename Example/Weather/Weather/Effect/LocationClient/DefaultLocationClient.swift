//
//  DefaultLocationClient.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 01.01.2023.
//

import Combine
import CoreLocation

struct DefaultLocationClient: LocationClient {
    func fetchLocation(by query: String) -> AnyPublisher<[Location], Error> {
        URLSession.shared
            .dataTaskPublisher(for: getUrl(query))
            .map { $0.data }
            .decode(type: LocationResponse.self, decoder: JSONDecoder())
            .map { $0.results ?? [] }
            .eraseToAnyPublisher()
    }

    private func getUrl(_ query: String) -> URL {
        var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")!
        components.queryItems = [URLQueryItem(name: "name", value: query)]
        return components.url!
    }
}

