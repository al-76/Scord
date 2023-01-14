//
//  WeatherClient.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 01.01.2023.
//

import Combine

protocol WeatherClient {
    func fetchWeather(by location: Location) -> AnyPublisher<Weather, Error>
}
