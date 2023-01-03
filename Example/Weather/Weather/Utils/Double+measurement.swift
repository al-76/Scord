//
//  Double+measurement.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 02.01.2023.
//

import Foundation

extension Double {
    func temperature() -> String {
        Measurement(value: self, unit: UnitTemperature.celsius)
            .formatted()
    }

    func speed() -> String {
        Measurement(value: self, unit: UnitSpeed.metersPerSecond)
            .formatted()
    }
}
