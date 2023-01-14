//
//  LoadRowsMiddlewareTests.swift
//  WeatherTests
//
//  Created by Vyacheslav Konopkin on 07.01.2023.
//

import Combine
import Scord
import XCTest

@testable import Weather

final class WeatherMiddlewareTests: XCTestCase {
    private var storage: FakeLocalStorage!
    private let uuidProvider = FakeUUIDProvider()
    private var store: TestStoreOf<WeatherReducer>!

    override func setUp() {
        uuidProvider.resetCounter()
        storage = FakeLocalStorage()
        store = TestStoreOf<WeatherReducer>(state: .init(),
                                            reducer: WeatherReducer(),
                                            middlewares: [
                                                WeatherMiddleware(storage: storage,
                                                                  uuidProvider: uuidProvider)
                                            ])
    }

    func testLoadData() {
        // Arrange
        let expectedItems = getItems()
        storage.loadAnswer = Answer.successAnswer(.stub)

        // Act
        store.submit(.loadWeatherItems)

        // Assert
        XCTAssertEqual(store.state, .init(weatherItems: expectedItems))
    }

    func testLoadDataError() {
        // Arrange
        storage.loadAnswer = Answer.failAnswer()

        // Act
        store.submit(.loadWeatherItems)

        // Assert
        XCTAssertEqual(store.state, .init(error: .init(TestError.someError)))
    }

    func testLoadDataSecondCall() {
        // Arrange
        storage.loadAnswer = Answer.successAnswer(.stub)

        // Act
        store.submit(.loadWeatherItems)
        store.submit(.loadWeatherItems)

        // Assert
        XCTAssertEqual(storage.loadCountCall, 1)
    }

    private func getItems() -> WeatherReducer.WeatherItems {
        let result = [Location].stub
            .reduce(into: WeatherReducer.WeatherItems()) {
                let id = uuidProvider.uuid()
                return $0[id] = .init(id: id, location: $1)
            }
        uuidProvider.resetCounter()
        return result
    }
}
