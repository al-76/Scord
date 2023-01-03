//
//  File.swift
//  
//
//  Created by Vyacheslav Konopkin on 04.01.2023.
//

import Combine

public func successAnswer<T>(_ data: T) -> AnyPublisher<T, Error> {
    Just(data)
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
}

public func failAnswer<T>(_ error: Error = TestError.someError) -> AnyPublisher<T, Error> {
    Fail<T, Error>(error: error)
        .eraseToAnyPublisher()
}

public func failAnswer<T>(_ error: Error, _ type: T.Type) -> AnyPublisher<T, Error> {
    Fail<T, Error>(error: error)
        .eraseToAnyPublisher()
}

public func noAnswer<T>() -> AnyPublisher<T, Error> {
    Empty<T, Error>()
        .eraseToAnyPublisher()
}
