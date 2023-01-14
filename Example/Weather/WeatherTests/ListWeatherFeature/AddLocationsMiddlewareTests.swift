//
//  AddLocationsMiddlewareTests.swift
//  WeatherTests
//
//  Created by Vyacheslav Konopkin on 07.01.2023.
//

import Combine
import Scord
import XCTest

@testable import Weather

final class AddLocationsMiddlewareTests: XCTestCase {
    private let uuidProvider = FakeUUIDProvider()
    private var storage: FakeLocalStorage!
    private var store: TestStoreOf<ListWeatherReducer>!

    override func setUp() {
        uuidProvider.resetCounter()
        storage = FakeLocalStorage()
        store = TestStoreOf<ListWeatherReducer>(state: .init(),
                                                reducer: ListWeatherReducer(uuidProvider: uuidProvider),
                                                middlewares: [
                                                    AddLocationsMiddleware(storage: storage)
                                                ])
    }

    func testAddLocations() {
        // Arrange
        let id = uuidProvider.uuid(counter: 0)
        storage.saveAnswer = Answer.successAnswer(())

        // Act
        store.submit(.addLocation(.stub))

        // Assert
        XCTAssertEqual(store.state, .init(weather:
                .init(weatherItems: [id: .init(id: id,
                                               location: .stub)])))
    }

    func testAddLocationsError() {
        // Arrange
        storage.saveAnswer = Answer.failAnswer()

        // Act
        store.submit(.addLocation(.stub))

        // Assert
        XCTAssertEqual(store.state, .init(error: .init(TestError.someError)))
    }
}
