//
//  File.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 15.08.25.
//

import SwiftUI

// MARK: - Flexibler Debugger Breakpoint
func triggerSchemeDeviceBreakpoint() {
    // 1️⃣ Schemes, für die der Breakpoint gelten soll
    //let targetSchemes = ["UltimatePortfolio", "AnotherScheme"]
    let targetSchemes = ["UltimatePortfolio"]

    // 2️⃣ Run Destinations / Devices
    //let targetDevices = ["iPhone 16 Pro Max iOS 18.5", "macOS", "iPhone 15 Pro"]
    let targetDevices = ["iPhone 16 Pro Max iOS 18.5"]

    // 3️⃣ Aktuelle Scheme prüfen
    let currentScheme = ProcessInfo.processInfo.environment["SCHEME"] ?? ""
    guard targetSchemes.contains(currentScheme) else { return }

    // 4️⃣ Aktuelles Device / Run Destination prüfen
    let currentDevice: String
    #if os(iOS)
    currentDevice = UIDevice.current.name
    #elseif os(macOS)
    currentDevice = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] ?? "macOS"
    #elseif os(watchOS)
    currentDevice = "watchOS"
    #else
    currentDevice = "Unknown"
    #endif

    guard targetDevices.contains(currentDevice) else { return }

    // 5️⃣ Debugger stoppen
    raise(SIGINT)
}
