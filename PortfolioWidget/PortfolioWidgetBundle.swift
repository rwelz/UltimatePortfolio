//
//  PortfolioWidgetBundle.swift
//  PortfolioWidgetBundle
//
//  Created by Robert Welz on 24.07.25.
//

import WidgetKit
import SwiftUI

@main
struct PortfolioWidgetBundle: WidgetBundle {
    var body: some Widget {
        SimplePortfolioWidget()
        ComplexPortfolioWidget()
    }
}
