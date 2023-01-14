//
//  Result+get.swift
//  Weather
//
//  Created by Vyacheslav Konopkin on 01.01.2023.
//

extension Result {
    func getResult() -> Success? {
        guard case .success(let success) = self else {
            return nil
        }
        return success
    }

    func getFailure() -> Failure? {
        guard case .failure(let failure) = self else {
            return nil
        }
        return failure
    }
}
