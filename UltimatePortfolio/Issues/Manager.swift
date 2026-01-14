//
//  Manager.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 21.07.25.
//
import Foundation
import SwiftUI

@MainActor
class Manager: ObservableObject {
    static let shared = Manager()

    @Published var showView: Bool = false

    func setShowView(_ flag: Bool) {
        "alter Wert: \(showView)".debugLog()
        showView = flag
        "neuer Wert: \(showView)".debugLog()
    }
}
