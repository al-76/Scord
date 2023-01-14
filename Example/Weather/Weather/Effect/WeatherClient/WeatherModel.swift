//
//  WeatherModel.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 01.01.2023.
//

import Foundation

struct Weather: Decodable, Equatable {
    let current: WeatherCurrent
    let daily: [WeatherDaily]
}

struct WeatherCurrent: Decodable, Equatable {
    let temperature: Double
    let windspeed: Double
    let weathercode: Weathercode
    let time: Date
}

struct WeatherDaily: Identifiable, Equatable {
    var id = UUID()
    let temperature: WeatherTemperature
    let time: Date
    let weathercode: Weathercode
}

struct WeatherTemperature: Equatable {
    let min: Double
    let max: Double
}

enum Weathercode: Int, Decodable, Equatable {
    case clear
    case cloud
    case fog
    case drizzle
    case freezingDrizzle
    case rain
    case freezingRain
    case snow
    case rainShower
    case thunderstorm
    case thunderstormHail
    case unknown

    func sfSymbol() -> String {
        switch self {
        case .clear:
            return "sun.max"

        case .cloud:
            return "cloud"

        case .fog:
            return "cloud.fog"

        case .drizzle:
            return "cloud.drizzle"

        case .freezingDrizzle:
            return "cloud.sleet"

        case .rain:
            return "cloud.rain"

        case .freezingRain:
            return "cloud.hail"

        case .snow:
            return "cloud.snow"

        case .rainShower:
            return "cloud.heavyrain"

        case .thunderstorm:
            return "cloud.bolt"

        case .thunderstormHail:
            return "cloud.bolt.rain"

        case .unknown:
            return ""
        }
    }
}

// MARK: - Parsing
private struct AnyKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        nil
    }
}

extension Weather {
    enum CodingKeys: String, CodingKey {
        case current = "current_weather"
        case daily
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        current = try container.decode(WeatherCurrent.self, forKey: .current)

        let dailyContainer = try container.nestedContainer(keyedBy: AnyKey.self, forKey: .daily)
        daily = try dailyContainer.decodeWeatherDaily()
    }
}

private extension KeyedDecodingContainer where K == AnyKey {
    func decodeWeatherDaily() throws -> [WeatherDaily] {
        guard let timeKey = AnyKey(stringValue: "time"),
              let temperatureMinKey = AnyKey(stringValue: "temperature_2m_min"),
              let temperatureMaxKey = AnyKey(stringValue: "temperature_2m_min"),
              let weatherCodeKey = AnyKey(stringValue: "weathercode") else {
            throw valueNotFoundError()
        }

        let temperatureMin = try decode([Double].self, forKey: temperatureMinKey)
        let temperatureMax = try decode([Double].self, forKey: temperatureMaxKey)
        let time = try decode([Date].self, forKey: timeKey)
        let weatherCode = try decode([Weathercode].self, forKey: weatherCodeKey)

        return zip(zip(temperatureMin, temperatureMax),
                   zip(time, weatherCode))
        .map { WeatherDaily(temperature: .init(min: $0.0, max: $0.1),
                            time: $1.0,
                            weathercode: $1.1) }
    }

    private func valueNotFoundError() -> DecodingError {
        DecodingError.valueNotFound(AnyKey.self,
                                    DecodingError.Context(codingPath: self.codingPath,
                                                        debugDescription: "Value not found"))
    }
}

extension Weathercode {
    init?(rawValue: Int) {
        switch rawValue {
        case 0: // Clear
            self = .clear

        case 1, 2, 3: // Mainly clear, partly cloudy, and overcast
            self = .cloud

        case 45, 48: // Fog and depositing rime fog
            self = .fog

        case 51, 53, 55: // Drizzle: Light, moderate, and dense intensity
            self = .drizzle

        case 56, 57: // Freezing Drizzle: Light and dense intensity
            self = .freezingDrizzle

        case 61, 63, 65: // Rain: Slight, moderate and heavy intensity
            self = .rain

        case 66, 67: // Freezing Rain: Light and heavy intensity
            self = .freezingRain

        case 77: // Snow grains
            fallthrough

        case 85, 86: // Snow showers slight and heavy
            fallthrough

        case 71, 73, 75: // Snow fall: Slight, moderate, and heavy intensity
            self = .snow

        case 80, 81, 82: // Rain showers: Slight, moderate, and violent
            self = .rainShower

        case 95: // Thunderstorm: Slight or moderate
            self = .thunderstorm

        case 96, 99: // Thunderstorm with slight and heavy hail
            self = .thunderstormHail

        default: // Unknown
            self = .unknown
        }
    }
}

// MARK: - Stub data
extension Weather {
    static let stub = Self(
        current: WeatherCurrent(temperature: 11.3,
                                windspeed: 6.6,
                                weathercode: .init(rawValue: 61)!,
                                time: Self.parseDate(from: "2023-01-02T03:00")),
        daily: [
            WeatherDaily(temperature: .init(min: 10.0, max: 14.5),
                         time: Self.parseDate(from: "2023-01-02"),
                         weathercode: .init(rawValue: 80)!),
            WeatherDaily(temperature: .init(min: 5.2, max: 9.5),
                         time: Self.parseDate(from: "2023-01-03"),
                         weathercode: .init(rawValue: 80)!),
            WeatherDaily(temperature: .init(min: 4.0, max: 9.3),
                         time: Self.parseDate(from: "2023-01-04"),
                         weathercode: .init(rawValue: 80)!),
            WeatherDaily(temperature: .init(min: 7.4, max: 9.5),
                         time: Self.parseDate(from: "2023-01-05"),
                         weathercode: .init(rawValue: 80)!),
            WeatherDaily(temperature: .init(min: 6.3, max: 11.1),
                         time: Self.parseDate(from: "2023-01-06"),
                         weathercode: .init(rawValue: 61)!),
            WeatherDaily(temperature: .init(min: 2.1, max: 7.0),
                         time: Self.parseDate(from: "2023-01-07"),
                         weathercode: .init(rawValue: 3)!),
            WeatherDaily(temperature: .init(min: 5.5, max: 8.3),
                         time: Self.parseDate(from: "2023-01-08"),
                         weathercode: .init(rawValue: 80)!)
        ]
    )

    private static var dateFormatterTime: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return formatter
    }

    private static var dateFormatterDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    static func parseDate(from string: String) -> Date {
        guard let date = dateFormatterTime.date(from: string) else {
            return dateFormatterDate.date(from: string)!
        }
        return date
    }
}
