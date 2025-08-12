//
//  NumberBadge.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 08.08.25.
//

import SwiftUI

extension View {
    func numberBadge(_ number: Int) -> some View {
        #if os(watchOS)
        self
        #else
        self.badge(number)
        #endif
    }
}
