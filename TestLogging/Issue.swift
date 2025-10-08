//
//  Issue.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 06.10.25.
//

import Foundation
import Combine

final class Issue: Comparable {
    // MARK: - Properties

    let id: UUID
    @Published var title: String
    @Published var content: String
    @Published var creationDate: Date
    @Published var modificationDate: Date
    @Published var priority: Int
    @Published var completed: Bool
    @Published var reminderTime: Date
    //@Published var tags: [Tag]

    // MARK: - Computed Properties

    var issueTitle: String {
        get { title }
        set { title = newValue }
    }

    var issueContent: String {
        get { content }
        set { content = newValue }
    }

    var issueCreationDate: Date {
        creationDate
    }

    var issueModificationDate: Date {
        modificationDate
    }

    //var issueTags: [Tag] {
    //    tags.sorted()
    //}

    var issueStatus: String {
        completed
        ? NSLocalizedString("Closed", comment: "This issue has been resolved by the user.")
        : NSLocalizedString("Open", comment: "This issue is currently unresolved.")
    }

    //var issueTagsList: String {
    //    let noTags = NSLocalizedString("No tags", comment: "The user has not created any tags yet")
    //    return tags.isEmpty ? noTags : issueTags.map(\.tagName).formatted()
    //}

    var issueReminderTime: Date {
        get { reminderTime }
        set { reminderTime = newValue }
    }

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        creationDate: Date = .now,
        modificationDate: Date = .now,
        priority: Int = 2,
        completed: Bool = false,
        reminderTime: Date = .now,
        //tags: [Tag] = []
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.priority = priority
        self.completed = completed
        self.reminderTime = reminderTime
        //self.tags = tags
    }

    // MARK: - Example Instance

    static var example: Issue {
        Issue(
            title: "Example Issue",
            content: "This is an example issue.",
            priority: 2,
            completed: false
        )
    }

    // MARK: - Comparable

    static func < (lhs: Issue, rhs: Issue) -> Bool {
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase

        if left == right {
            return lhs.issueCreationDate < rhs.issueCreationDate
        } else {
            return left < right
        }
    }

    static func == (lhs: Issue, rhs: Issue) -> Bool {
        lhs.id == rhs.id
    }
}
