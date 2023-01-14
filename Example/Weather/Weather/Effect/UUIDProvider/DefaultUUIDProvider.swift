//
//  DefaultUUIDProvider.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 07.01.2023.
//

import Foundation

struct DefaultUUIDProvider: UUIDProvider {
    func uuid() -> UUID {
        UUID()
    }
}
