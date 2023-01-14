//
//  FakeLocationClient.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 01.01.2023.
//

import Combine

final class FakeLocationClient: LocationClient {
    var answer = Just([Location].stub)
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()

    func fetchLocation(by query: String) -> AnyPublisher<[Location], Error> {
        answer
    }
}
