//
//  FetchWeatherMiddlewareTests+PagerWeather.swift
//  WeatherTests
//
//  Created by Vyacheslav Konopkin on 31.12.2022.
//

import Combine
import Scord
import XCTest

@testable import Weather

final class FetchWeatherMiddlewareTests: XCTestCase {
    private let testId = UUID()
    private var client: FakeWeatherClient!
    private var store: TestStoreOf<FetchWeatherReducer>!

    override func setUp() {
        client = FakeWeatherClient()
        store = TestStoreOf<FetchWeatherReducer>(state: .init(id: testId, location: .stub),
                                                 reducer: FetchWeatherReducer(),
                                                 middlewares: [
                                                    FetchWeatherMiddleware(client: client)
                                                 ])
    }

    func testFetchWeather() {
        // Arrange
        client.answer = Answer.successAnswer(.stub)

        // Act
        store.submit(.fetchWeather)

        // Assert
        XCTAssertEqual(store.state, .init(id: testId,
                                          location: .stub,
                                          weather: .stub,
                                          isLoading: false))
    }

    func testFetchWeatherProcess() {
        // Arrange
        client.answer = Answer.successAnswer(.stub)

        // Act
        store.submit(.fetchWeatherProcess)

        // Assert
        XCTAssertEqual(store.state, .init(id: testId,
                                          location: .stub,
                                          weather: .stub,
                                          isLoading: false))
    }

    func testWeatherError() {
        // Arrange
        client.answer = Answer.failAnswer()

        // Act
        store.submit(.fetchWeather)

        // Assert
        XCTAssertEqual(store.state, .init(id: testId,
                                          location: .stub,
                                          isLoading: false,
                                          error: .init(TestError.someError)))
    }
}
