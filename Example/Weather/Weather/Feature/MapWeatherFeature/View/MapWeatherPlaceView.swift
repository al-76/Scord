//
//  MapWeatherPlaceView.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 12.01.2023.
//

import Scord
import SwiftUI

struct MapWeatherPlaceView: View {
    var body: some View {
        VStack {
            Image(systemName: "cloud.sun.fill")
                .foregroundStyle(.gray, .blue)
            Text(0.5.temperature())
                .bold()
                .foregroundColor(.blue)
        }
        .background(Circle()
            .scale(1.5)
            .foregroundColor(.yellow)
            .opacity(0.8))
    }
}

struct MapWeatherPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        MapWeatherPlaceView()
    }
}
