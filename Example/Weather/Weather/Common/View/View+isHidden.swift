//
//  View+isHidden.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 07.01.2023.
//

import SwiftUI

extension View {
    func isHidden(_ value: Bool) -> some View {
        opacity(value ? 1.0 : 0.0)
    }
}
