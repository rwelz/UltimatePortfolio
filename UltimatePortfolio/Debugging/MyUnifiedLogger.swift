//
//  MyUnifiedLogger.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 20.08.25.
//

import Foundation
import os
#if canImport(UIKit)
import UIKit
#endif

// Loglevel .debug taucht nur im Xcode Logfenster auf, nicht im Device Log des iPhones,
// weder wenn es in der App ausführt wird, noch als attached widget.
// erst ab .notice (dass ist der default) wird in beiden geloggt.
// There are five log types in increasing order of severity:
// debug
// info
// notice (default)
// error
// fault

struct MyUnifiedLogger {

    // static let widgetLogger = Logger(subsystem: "de.robert.welz.UltimatePortfolio", category: "Widget")

    private static let subsystem = "de.robert.welz.UltimatePortfolio"

    // MARK: - LogLevel (als Konstanten verwendbar)
    enum LogLevel {
        case debug
        case info
        case notice
        case error
        case fault
    }

    static func logString(_ text: String, loglevel: LogLevel = .notice) {
        let myPlatform = currentPlatform()
        let targetName = currentTargetName()

        let logger = Logger(subsystem: subsystem, category: myPlatform)

        guard !text.isEmpty else {
            log(logger, level: .fault, "[\(targetName)] <logString text is empty, this is a bug.>")
            return
        }

        log(logger, level: loglevel, "[\(targetName)] \(text)")
    }

    static func logTopIssues( resultSet: [Issue], loglevel: LogLevel = .notice) {
        let myPlatform = currentPlatform()
        let targetName = currentTargetName()

        let logger = Logger(subsystem: subsystem, category: myPlatform)
        // Anlegen der Logger Klasse hat niedrige Kosten laut Apple, kann also in hoher Frequenz erfolgen

        log(logger, level: loglevel, "[\(targetName)] logTopIssues called with \(resultSet.count) issues")

        guard !resultSet.isEmpty else {
            log(logger, level: loglevel, "[\(targetName)] <no Issues found>")
            return
        }

        for issue in resultSet {
            log(logger, level: loglevel, "[\(targetName)] Issue: \(issue.issueTitle)")
        }
    }

    static func logIssuesCount( resultSet: [Issue], loglevel: LogLevel = .notice) {
        let myPlatform = currentPlatform()
        let targetName = currentTargetName()

        let logger = Logger(subsystem: subsystem, category: myPlatform)
        // Anlegen der Logger Klasse hat niedrige Kosten laut Apple, kann also in hoher Frequenz erfolgen

        log(logger, level: loglevel, "[\(targetName)] #Issues found: \(resultSet.count)")
    }

    static func logData( data: Any, loglevel: LogLevel = .notice) {
        let myPlatform = currentPlatform()
        let targetName = currentTargetName()

        let logger = Logger(subsystem: subsystem, category: myPlatform)

        // If it's a String, validate it's not empty; otherwise, log a fault and return
        if let stringValue = data as? String {
            if stringValue.isEmpty {
                log(logger, level: .fault, "[\(targetName)] <logString data as String is empty, this is a bug.>")
                return
            }
            log(logger, level: loglevel, "[\(targetName)] \(stringValue)")
            return
        }

        // For non-String values, log their description
        let description = String(describing: data)
        if description.isEmpty {
            log(logger, level: .fault, "[\(targetName)] <unexpectedly, description of data was empty, this is a bug.>")
            return
        }
        log(logger, level: loglevel, "[\(targetName)] \(description)")
    }

    // MARK: - Generischer Logger
    private static func log(_ logger: Logger, level: LogLevel, _ message: String) {
        switch level {
        case .debug:
            logger.debug("\(message, privacy: .public)")
        case .info:
            logger.info("\(message, privacy: .public)")
        case .notice:
            logger.notice("\(message, privacy: .public)")
        case .error:
            logger.error("\(message, privacy: .public)")
        case .fault:
            logger.fault("\(message, privacy: .public)")
        }
    }

    private static func currentPlatform() -> String {
#if os(watchOS)
        return ".Watch"
#elseif os(tvOS)
        return ".TV"
#elseif os(macOS)
        return ".Mac"
#elseif os(iOS)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: return ".iPhone"
        case .pad: return ".iPad"
        case .mac: return ".Mac"
        case .tv: return ".TV"
        case .carPlay: return ".CarPlay"
        default: return ".Unknown"
        }
#else
        return ".Unknown"
#endif
    }

    // MARK: - Helper: Targetname
    private static func currentTargetName() -> String {
        // Der Targetname steckt im Bundle Display Name oder Executable Name
        let bundle = Bundle.main
        if let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return displayName
        } else if let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String {
            return name
        } else if let executable = bundle.object(forInfoDictionaryKey: "CFBundleExecutable") as? String {
            return executable
        }
        return "UnknownTarget"
    }
}
