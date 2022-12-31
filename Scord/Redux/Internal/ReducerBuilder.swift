//
//  ReducerBuilder.swift
//  Scord
//
//  Created by Vyacheslav Konopkin on 30.12.2022.
//

import Combine

@resultBuilder
enum ReducerBuilder<State, Action> {
    static func buildBlock() -> some Reducer<State, Action> {
        EmptyReducer()
    }

    static func buildBlock(_ reducer: some Reducer<State, Action>) -> some Reducer<State, Action> {
        reducer
    }

    static func buildBlock<T0: Reducer,
                           T1: Reducer>(_ reducer0: T0,
                                        _ reducer1: T1) -> ReducerTuple<T0, T1>
    where T0.State == State, T0.Action == Action {
        ReducerTuple(reducer0, reducer1)
    }

    static func buildBlock<T0: Reducer,
                           T1: Reducer,
                           T2: Reducer>(_ reducer0: T0,
                                        _ reducer1: T1,
                                        _ reducer2: T2) -> ReducerTuple3<T0, T1, T2>
    where T0.State == State, T0.Action == Action {
        ReducerTuple(
            ReducerTuple(reducer0, reducer1), reducer2)
    }

    static func buildBlock<T0: Reducer,
                           T1: Reducer,
                           T2: Reducer,
                           T3: Reducer>(_ reducer0: T0,
                                        _ reducer1: T1,
                                        _ reducer2: T2,
                                        _ reducer3: T3) -> ReducerTuple4<T0, T1, T2, T3>
    where T0.State == State, T0.Action == Action {
        ReducerTuple(
            ReducerTuple(
                ReducerTuple(reducer0, reducer1), reducer2),
            reducer3)
    }

    static func buildBlock<T0: Reducer,
                           T1: Reducer,
                           T2: Reducer,
                           T3: Reducer,
                           T4: Reducer>(_ reducer0: T0,
                                        _ reducer1: T1,
                                        _ reducer2: T2,
                                        _ reducer3: T3,
                                        _ reducer4: T4) -> ReducerTuple5<T0, T1, T2, T3, T4>
    where T0.State == State, T0.Action == Action {
        ReducerTuple(
            ReducerTuple(
                ReducerTuple(
                    ReducerTuple(reducer0, reducer1),
                    reducer2),
                reducer3),
            reducer4)
    }

    static func buildBlock<T0: Reducer,
                           T1: Reducer,
                           T2: Reducer,
                           T3: Reducer,
                           T4: Reducer,
                           T5: Reducer>(_ reducer0: T0,
                                        _ reducer1: T1,
                                        _ reducer2: T2,
                                        _ reducer3: T3,
                                        _ reducer4: T4,
                                        _ reducer5: T5) -> ReducerTuple6<T0, T1, T2, T3, T4, T5>
    where T0.State == State, T0.Action == Action {
        ReducerTuple(
            ReducerTuple(
                ReducerTuple(
                    ReducerTuple(
                        ReducerTuple(reducer0, reducer1),
                        reducer2),
                    reducer3),
                reducer4),
            reducer5)
    }

    static func buildBlock<T0: Reducer,
                           T1: Reducer,
                           T2: Reducer,
                           T3: Reducer,
                           T4: Reducer,
                           T5: Reducer,
                           T6: Reducer>(_ reducer0: T0,
                                        _ reducer1: T1,
                                        _ reducer2: T2,
                                        _ reducer3: T3,
                                        _ reducer4: T4,
                                        _ reducer5: T5,
                                        _ reducer6: T6) -> ReducerTuple7<T0, T1, T2, T3, T4, T5, T6>
    where T0.State == State, T0.Action == Action {
        ReducerTuple(
            ReducerTuple(
                ReducerTuple(
                    ReducerTuple(
                        ReducerTuple(
                            ReducerTuple(reducer0, reducer1),
                            reducer2),
                        reducer3),
                    reducer4),
                reducer5),
            reducer6)
    }

    static func buildBlock<T0: Reducer,
                           T1: Reducer,
                           T2: Reducer,
                           T3: Reducer,
                           T4: Reducer,
                           T5: Reducer,
                           T6: Reducer,
                           T7: Reducer>(_ reducer0: T0,
                                        _ reducer1: T1,
                                        _ reducer2: T2,
                                        _ reducer3: T3,
                                        _ reducer4: T4,
                                        _ reducer5: T5,
                                        _ reducer6: T6,
                                        _ reducer7: T7) -> ReducerTuple8<T0, T1, T2, T3, T4, T5, T6, T7>
    where T0.State == State, T0.Action == Action {
        ReducerTuple(
            ReducerTuple(
                ReducerTuple(
                    ReducerTuple(
                        ReducerTuple(
                            ReducerTuple(
                                ReducerTuple(reducer0, reducer1),
                                reducer2),
                            reducer3),
                        reducer4),
                    reducer5),
                reducer6),
            reducer7)
    }

    static func buildExpression(_ expression: some Reducer<State, Action>) -> some Reducer<State, Action> {
        expression
    }

    static func buildArray(_ reducers: [some Reducer<State, Action>]) -> some Reducer<State, Action> {
        ReducerCollection(elements: reducers)
    }
}

struct ReducerTuple<T0: Reducer,
                    T1: Reducer>: Reducer
where T0.State == T1.State, T0.Action == T1.Action
{
    private var reducer0: T0
    private var reducer1: T1

    init(_ reducer0: T0, _ reducer1: T1) {
        self.reducer0 = reducer0
        self.reducer1 = reducer1
    }

    func reduce(state: inout T0.State, action: T0.Action) {
        reducer0.reduce(state: &state, action: action)
        reducer1.reduce(state: &state, action: action)
    }
}

typealias ReducerTuple3<T0: Reducer,
                       T1: Reducer,
                       T2: Reducer> = ReducerTuple<ReducerTuple<T0, T1>, T2>
where T0.Action == T1.Action,
T0.State == T1.State,
T1.Action == T2.Action,
T1.State == T2.State

typealias ReducerTuple4<T0: Reducer,
                       T1: Reducer,
                       T2: Reducer,
                       T3: Reducer> = ReducerTuple<ReducerTuple3<T0, T1, T2>, T3>
where T0.Action == T1.Action,
T0.State == T1.State,
T1.Action == T2.Action,
T1.State == T2.State,
T2.Action == T3.Action,
T2.State == T3.State

typealias ReducerTuple5<T0: Reducer,
                       T1: Reducer,
                       T2: Reducer,
                       T3: Reducer,
                       T4: Reducer> = ReducerTuple<ReducerTuple4<T0, T1, T2, T3>, T4>
where T0.Action == T1.Action,
T0.State == T1.State,
T1.Action == T2.Action,
T1.State == T2.State,
T2.Action == T3.Action,
T2.State == T3.State,
T3.State == T4.State,
T3.Action == T4.Action

typealias ReducerTuple6<T0: Reducer,
                       T1: Reducer,
                       T2: Reducer,
                       T3: Reducer,
                       T4: Reducer,
                       T5: Reducer> = ReducerTuple<ReducerTuple5<T0, T1, T2, T3, T4>, T5>
where T0.Action == T1.Action,
T0.State == T1.State,
T1.Action == T2.Action,
T1.State == T2.State,
T2.Action == T3.Action,
T2.State == T3.State,
T3.State == T4.State,
T3.Action == T4.Action,
T4.State == T5.State,
T4.Action == T5.Action

typealias ReducerTuple7<T0: Reducer,
                       T1: Reducer,
                       T2: Reducer,
                       T3: Reducer,
                       T4: Reducer,
                       T5: Reducer,
                       T6: Reducer> = ReducerTuple<ReducerTuple6<T0, T1, T2, T3, T4, T5>, T6>
where T0.Action == T1.Action,
T0.State == T1.State,
T1.Action == T2.Action,
T1.State == T2.State,
T2.Action == T3.Action,
T2.State == T3.State,
T3.State == T4.State,
T3.Action == T4.Action,
T4.State == T5.State,
T4.Action == T5.Action,
T5.State == T6.State,
T5.Action == T6.Action

typealias ReducerTuple8<T0: Reducer,
                       T1: Reducer,
                       T2: Reducer,
                       T3: Reducer,
                       T4: Reducer,
                       T5: Reducer,
                       T6: Reducer,
                       T7: Reducer> = ReducerTuple<ReducerTuple7<T0, T1, T2, T3, T4, T5, T6>, T7>
where T0.Action == T1.Action,
T0.State == T1.State,
T1.Action == T2.Action,
T1.State == T2.State,
T2.Action == T3.Action,
T2.State == T3.State,
T3.State == T4.State,
T3.Action == T4.Action,
T4.State == T5.State,
T4.Action == T5.Action,
T5.State == T6.State,
T5.Action == T6.Action,
T6.State == T7.State,
T6.Action == T7.Action
