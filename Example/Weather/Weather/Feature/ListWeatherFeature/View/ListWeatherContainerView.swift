//
//  ListWeatherContainerView.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 13.01.2023.
//

import Scord
import SwiftUI

struct ListWeatherContainerView: View {
    @StateObject var store: StoreOf<ListWeatherReducer>

    var body: some View {
        Text("Hello, World!")
    }
}

struct ListWeatherContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ListWeatherContainerView(store: StoreOf<ListWeatherReducer>(
            state: .init(),
            reducer: ListWeatherReducer(uuidProvider: DefaultUUIDProvider())
        ))
    }
}
