//
//  LocalStorage.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 01.01.2023.
//

import Combine
import Foundation

protocol LocalStorage<T> {
    associatedtype T: Codable

    func save(item: T) -> AnyPublisher<Void, Error>
    func load() -> AnyPublisher<[T], Error>
}
