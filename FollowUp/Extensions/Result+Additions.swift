//
//  Result+Additions.swift
//  FollowUp
//
//  Created by Aaron Baw on 16/03/2023.
//

import Foundation

extension Result {
    func tryMap<NewSuccess>(_ transform: (Success) throws -> NewSuccess) -> Result<NewSuccess, Error> {
        switch self {
        case let .success(value):
            do {
                let newValue = try transform(value)
                return .success(newValue)
            } catch {
                return .failure(error)
            }
        case let .failure(error):
            return .failure(error)
        }
    }
}
