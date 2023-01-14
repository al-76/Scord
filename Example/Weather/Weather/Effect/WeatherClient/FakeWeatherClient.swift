//
//  FakeWeatherClient.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 03.01.2023.
//

import Combine

final class FakeWeatherClient: WeatherClient {
    var answer = Just(Weather.stub)
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()

    func fetchWeather(by location: Location) -> AnyPublisher<Weather, Error> {
        answer
    }
}
