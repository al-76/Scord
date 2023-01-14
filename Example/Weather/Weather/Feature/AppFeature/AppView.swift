//
//  AppView.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 31.12.2022.
//

import SwiftUI
import Scord

struct AppView: View {
    private enum Tabs: Hashable {
        case pager
        case list
    }

    @StateObject var store = Dependency.appStore()
    @State private var selectedTab = Tabs.pager

    var body: some View {
        TabView(selection: $selectedTab) {
            PagerWeatherView(store: store
                .scope(state: \.pagerWeather,
                       scopeAction: AppReducer.Action.pagerWeatherAction)
                .applyMiddlewares()
            ) {
                selectedTab = .list
            }
            .tabItem { Image(systemName: "cloud.sun")}
            .tag(Tabs.pager)

            ListWeatherView(store: store
                .scope(state: \.listWeather,
                       scopeAction: AppReducer.Action.listWeatherAction)
                .applyMiddlewares()
            )
            .tabItem { Image(systemName: "list.dash") }
            .tag(Tabs.list)
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
