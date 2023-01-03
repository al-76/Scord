//
//  Answer.swift
//  
//
//  Created by Vyacheslav Konopkin on 04.01.2023.
//

import Combine

public enum Answer {
    public static func successAnswer<T>(_ data: T) -> AnyPublisher<T, Error> {
        Just(data)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public static func failAnswer<T>(_ error: Error = TestError.someError) -> AnyPublisher<T, Error> {
        Fail<T, Error>(error: error)
            .eraseToAnyPublisher()
    }

    public static func failAnswer<T>(_ error: Error, _ type: T.Type) -> AnyPublisher<T, Error> {
        Fail<T, Error>(error: error)
            .eraseToAnyPublisher()
    }

    public static func noAnswer<T>() -> AnyPublisher<T, Error> {
        Empty<T, Error>()
            .eraseToAnyPublisher()
    }
}
