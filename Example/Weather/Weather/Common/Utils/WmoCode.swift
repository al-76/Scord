//
//  WmoCode.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 02.01.2023.
//

import Foundation

enum WmoCode {
    static func sfSymbol(code: Int) -> String {
        switch code {
        case 0: // Clear
            return "sun.max"

        case 1, 2, 3: // Mainly clear, partly cloudy, and overcast
            return "cloud"

        case 45, 48: // Fog and depositing rime fog
            return "cloud.fog"

        case 51, 53, 55: // Drizzle: Light, moderate, and dense intensity
            return "cloud.drizzle"

        case 56, 57: // Freezing Drizzle: Light and dense intensity
            return "cloud.sleet"

        case 61, 63, 65: // Rain: Slight, moderate and heavy intensity
            return "cloud.rain"

        case 66, 67: // Freezing Rain: Light and heavy intensity
            return "cloud.hail"

        case 77: // Snow grains
            fallthrough

        case 85, 86: // Snow showers slight and heavy
            fallthrough

        case 71, 73, 75: // Snow fall: Slight, moderate, and heavy intensity
            return "cloud.snow"

        case 80, 81, 82: // Rain showers: Slight, moderate, and violent
            return "cloud.heavyrain"

        case 95: // Thunderstorm: Slight or moderate
            return "cloud.bolt"

        case 96, 99: // Thunderstorm with slight and heavy hail
            return "cloud.bolt.rain"

        default: // Unknown
            return ""
        }
    }
}
