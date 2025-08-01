//
//  Issue-CoreDataHelpers.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 13.05.25.
//

import Foundation

extension Issue {
    var issueTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }

    var issueContent: String {
        get { content ?? "" }
        set { content = newValue }
    }

    var issueCreationDate: Date {
        creationDate ?? .now
    }

    var issueModificationDate: Date {
        modificationDate ?? .now
    }

    var issueTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }

    static var example: Issue {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let issue = Issue(context: viewContext)
        issue.title = "Example Issue"
        issue.content = "This is an example issue."
        issue.priority = 2
        issue.creationDate = .now
        issue.completed = false
        return issue
    }

    var issueStatus: String {
        if completed {
            return NSLocalizedString("Closed", comment: "This issue has been resolved by the user.")
        } else {
            return NSLocalizedString("Open", comment: "This issue is currently unresolved.")
        }
    }

    var issueTagsList: String {
        let noTags = NSLocalizedString("No tags", comment: "The user has not created any tags yet")

        guard let tags else { return noTags }
// TODO:
// swiftlint:disable empty_count
        if tags.count == 0 {
// swiftlint:enable empty_count
            return noTags
        } else {
            return issueTags.map(\.tagName).formatted()
        }
    }

    var issueReminderTime: Date {
        get { reminderTime ?? .now }
        set { reminderTime = newValue }
    }
}

extension Issue: Comparable {
    public static func < (lhs: Issue, rhs: Issue) -> Bool {
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase

        if left == right {
            return lhs.issueCreationDate < rhs.issueCreationDate
        } else {
            return left < right
        }
    }
}
