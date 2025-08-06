//
//  PlatformAdjustments/InlineNavigationBar.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 04.08.25.
//

import SwiftUI

extension View {
    func inlineNavigationBar() -> some View {
        #if os(macOS)
        self
        #else
        self.navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
