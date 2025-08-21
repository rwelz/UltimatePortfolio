//
//  MyUnifiedLogger.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 20.08.25.
//

import Foundation
import os
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

    static func logTopIssues(from dataController: DataController, count: Int = 1, category: String) {
        let logger = Logger(subsystem: subsystem, category: category)
        // Anlegen der Logger Klasse hat niedrige Kosten laut Apple, kann also in hoher Frequenz erfolgen

        let dataController = DataController()
        let request = dataController.fetchRequestForTopIssues(count: count)
        let result = dataController.results(for: request)

        if result.isEmpty {
            logger.notice("<no Issues found>")
            return
        }

        for issue in result {
            logger.notice("Issue: \(issue.issueTitle, privacy: .public)")
        }
    }

    static func logTopIssues( resultSet: [Issue], category: String) {
        let logger = Logger(subsystem: subsystem, category: category)
        // Anlegen der Logger Klasse hat niedrige Kosten laut Apple, kann also in hoher Frequenz erfolgen
        logger.notice("logTopIssues called with \(resultSet.count) issues")

        if resultSet.isEmpty {
            logger.notice("<no Issues found>")
            return
        }

        for issue in resultSet {
            logger.notice("Issue: \(issue.issueTitle, privacy: .public)")
        }
    }

    static func logIssuesCount( from dataController: DataController, category: String) {
        let logger = Logger(subsystem: subsystem, category: category)
        // Anlegen der Logger Klasse hat niedrige Kosten laut Apple, kann also in hoher Frequenz erfolgen

        let dataController = DataController()
        let request = dataController.fetchRequestForTopIssues(count: 1)
        let result = dataController.results(for: request)

        logger.notice("#Issues found: \(result[0].issueTitle, privacy: .public)")
    }

    static func logIssuesCount( resultSet: [Issue], category: String) {
        let logger = Logger(subsystem: subsystem, category: category)
        // Anlegen der Logger Klasse hat niedrige Kosten laut Apple, kann also in hoher Frequenz erfolgen

        logger.notice("#Issues found: \(resultSet.count)")
    }
}
