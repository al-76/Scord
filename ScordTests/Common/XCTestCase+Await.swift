//
//  XCTestCase+Await.swift
//  ScordTests
//
// Inspired:
// https://www.swiftbysundell.com/articles/unit-testing-combine-based-swift-code/
//
//  Created by Vyacheslav Konopkin on 27.12.2022.
//

import Combine
import XCTest

enum TestAwaitError: Error {
    case unexpectedResult
}

extension XCTestCase {
    @discardableResult
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        let result = awaitAction(publisher, timeout)

        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )

        return try unwrappedResult.get()
    }

    @discardableResult
    func awaitError<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Failure {
        let result = awaitAction(publisher, timeout)

        let unwrappedResult = try XCTUnwrap(
            result,
            "Awaited publisher did not produce any output",
            file: file,
            line: line
        )

        if case .failure(let error) = unwrappedResult {
            return error
        }

        throw TestAwaitError.unexpectedResult
    }

    private func awaitAction<T: Publisher>(
        _ publisher: T,
        _ timeout: TimeInterval) -> Result<T.Output, T.Failure>? {
        var result: Result<T.Output, T.Failure>?
        let expectation = self.expectation(description: "Awaiting publisher")

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    result = .failure(error)
                    expectation.fulfill()
                    break
                case .finished:
                    break
                }
            },
            receiveValue: { value in
                result = .success(value)
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: timeout)
        cancellable.cancel()

        return result
    }
}
