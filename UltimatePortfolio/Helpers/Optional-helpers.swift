//
//  Optional-helpers.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 07.10.25.
//

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        switch self {
        case .none:
            return true
        case .some(let value):
            return value.isEmpty
        }
    }
}
