//
//  MyUnifiedLogger.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 20.08.25.
//

import Foundation
import os

struct MyUnifiedLogger
{
    //static let widgetLogger = Logger(subsystem: "de.robert.welz.UltimatePortfolio", category: "Widget")

    private static let subsystem = "de.robert.welz.UltimatePortfolio"
    //static let widget = Logger(subsystem: subsystem, category: "Widget")
    //static let app = Logger(subsystem: subsystem, category: "App")

    static func logTopIssues(from dataController: DataController, count: Int = 1, category: String) {
        let logger = Logger(subsystem: subsystem, category: category)

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
        logger.notice("logTopIssues called with \(resultSet.count) issues")

        if resultSet.isEmpty {
            logger.notice("<no Issues found>")
            return
        }

        for issue in resultSet {
            logger.notice("Issue: \(issue.issueTitle, privacy: .public)")
        }
    }

    static func logIssuesCount( from dataController: DataController , category: String) {
        let logger = Logger(subsystem: subsystem, category: category)

        let dataController = DataController()
        let request = dataController.fetchRequestForTopIssues(count: 1)
        let result = dataController.results(for: request)

        logger.notice("#Issues found: \(result[0].issueTitle, privacy: .public)")
    }

    static func logIssuesCount( resultSet: [Issue], category: String) {
        let logger = Logger(subsystem: subsystem, category: category)

        logger.notice("#Issues found: \(resultSet.count)")
    }
}
