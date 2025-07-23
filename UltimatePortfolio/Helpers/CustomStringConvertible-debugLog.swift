//
//  helpers.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 22.07.25.
//

extension CustomStringConvertible {
    func debugLog() {
        #if DEBUG
        print(self)
        #endif
    }
}
