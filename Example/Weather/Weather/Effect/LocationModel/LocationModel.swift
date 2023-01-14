//
//  LocationModel.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 01.01.2023.
//

import CoreLocation

struct LocationResponse: Decodable {
    let results: [Location]?
}

struct Location: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let country: String
    let latitude: Double
    let longitude: Double
}

// - MARK: Stub data
extension Location {
    static let stub = Self(
        id: 0,
        name: "Stockholm",
        country: "Sweden",
        latitude: 59.3293,
        longitude: 18.0686
    )
}

extension Array where Element == Location {
    static let stub = [
        Location(id: 0,
                 name: "Stockholm",
                 country: "Sweden",
                 latitude: 59.3293,
                 longitude: 18.0686),
        Location(id: 1,
                 name: "Berlin",
                 country: "Germany",
                 latitude: 52.5200,
                 longitude: 13.4050),
        Location(id: 2,
                 name: "Amsterdam",
                 country: "Netherlands",
                 latitude: 52.3676,
                 longitude: 4.9041),
        Location(id: 3,
                 name: "Zurich",
                 country: "Switzerland",
                 latitude: 47.3769,
                 longitude: 8.5417)
    ]
}
