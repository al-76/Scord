//
//  TextDebouncer.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 06.01.2023.
//

import Foundation

final class TextDebouncer: ObservableObject {
    @Published var input: String = ""
    @Published var output: String = ""

    init(interval: DispatchQueue.SchedulerTimeType.Stride = .seconds(0.4)) {
        $input
            .removeDuplicates()
            .debounce(for: interval, scheduler: DispatchQueue.main)
            .assign(to: &$output)
    }
}
