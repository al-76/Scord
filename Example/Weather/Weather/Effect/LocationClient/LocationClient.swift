//
//  LocationClient.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 01.01.2023.
//

import Combine

protocol LocationClient {
    func fetchLocation(by query: String) -> AnyPublisher<[Location], Error>
}
