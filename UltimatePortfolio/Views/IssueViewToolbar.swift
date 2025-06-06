//
//  IssueViewToolbar.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 05.06.25.
//

import SwiftUI

struct IssueViewToolbar: View {
    @ObservedObject var issue: Issue
    @EnvironmentObject var dataController: DataController

    var openCloseButtonText: LocalizedStringKey {
        issue.completed ? "Re-open Issue" : "Close Issue"
    }

    var body: some View {
        Menu {
            Button {
                UIPasteboard.general.string = issue.title
            } label: {
                Label("Copy Issue Title", systemImage: "doc.on.doc")
            }

            Button {
                issue.completed.toggle()
                dataController.save()
            } label: {
                Label(openCloseButtonText, systemImage: "bubble.left.and.exclamationmark.bubble.right")
            }

            Divider()

            Section("Tags") {
                TagsMenuView(issue: issue) // Can be added to menu, handled automatically by SwiftUI - its a trick
            }
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
        }

    }
}

#Preview {
    IssueViewToolbar(issue: Issue.example)
        .environmentObject(DataController(inMemory: true))
    }
