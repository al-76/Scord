//
//  Utils.swift
//  Scord
//
//  Created by Vyacheslav Konopkin on 09.01.2023.
//

import OrderedCollections

public typealias IdDictionary<T> = OrderedDictionary<T.ID, T> where T: Identifiable
