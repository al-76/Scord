//
//  ListWeatherSheetView.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 13.01.2023.
//

import Scord
import SwiftUI

struct ListWeatherSheetView: View {
    @StateObject var store: StoreOf<FetchWeatherReducer>

    let isAddedLocation: Bool
    var onAddLocation: () -> Void
    var onExit: () -> Void

    var body: some View {
        VStack(alignment: .trailing) {
            HStack {
                Spacer()
                Button("Add") {
                    onAddLocation()
                    //                            if let location = selectedLocation {
                    //                                store.submit(.addLocation(location))
                    //                            }
                    //                            selectedLocation = nil
                }
                .padding(8)
                .buttonStyle(.bordered)
                .isHidden(!isAddedLocation)
            }
            Spacer()
            WeatherView(store: store)
            Spacer()
        }
        .onTapGesture {
//            selectedLocation = nil
            onExit()
        }
    }
}

struct ListWeatherSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ListWeatherSheetView(store: StoreOf<FetchWeatherReducer>(
            state: .init(id: UUID(), location: .stub),
            reducer: FetchWeatherReducer()
        ))
    }
}
