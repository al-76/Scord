//
//  FetchLocationsMiddlewareTests.swift
//  WeatherTests
//
//  Created by Vyacheslav Konopkin on 07.01.2023.
//

import Combine
import Scord
import XCTest

@testable import Weather

final class FetchLocationsMiddlewareTests: XCTestCase {
    private var client: FakeLocationClient!
    private var store: TestStoreOf<ListWeatherReducer>!

    override func setUp() {
        client = FakeLocationClient()
        store = TestStoreOf<ListWeatherReducer>(state: .init(),
                                                reducer: ListWeatherReducer(uuidProvider: DefaultUUIDProvider()),
                                                middlewares: [
                                                    FetchLocationsMiddleware(client: client)
                                                ])
    }

    func testFetchLocations() {
        // Arrange
        client.answer = Answer.successAnswer(.stub)

        // Act
        store.submit(.fetchLocations("test"))

        // Assert
        XCTAssertEqual(store.state, .init(locations: .stub,
                                          isLoading: false))
    }

    func testFetchLocationsShortQuery() {
        // Act
        store.submit(.fetchLocations("t"))

        // Assert
        XCTAssertEqual(store.state, .init(locations: [],
                                          isLoading: false))
    }

    func testFetchLocationsError() {
        // Arrange
        client.answer = Answer.failAnswer()

        // Act
        store.submit(.fetchLocations("test"))

        // Assert
        XCTAssertEqual(store.state, .init(error: .init(TestError.someError)))
    }
}
