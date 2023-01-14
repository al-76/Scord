//
//  FakeUUIDProvider.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 07.01.2023.
//

import Foundation

final class FakeUUIDProvider: UUIDProvider {
    static private var counter = 0

    func uuid() -> UUID {
        defer {
            Self.counter += 1
        }
        return uuid(counter: Self.counter)
    }

    func uuid(counter: Int) -> UUID {
        let stringCounter = "\(counter)"
            .padding(toLength: 12, withPad: "0", startingAt: 0)
        return UUID(uuidString: "00000000-0000-0000-0000-\(stringCounter)")!
    }

    func resetCounter() {
        Self.counter = 0
    }
}
