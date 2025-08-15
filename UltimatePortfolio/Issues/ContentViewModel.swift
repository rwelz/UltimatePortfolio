//
//  ContentViewModel.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 20.06.25.
//

import Foundation

extension ContentView {
    @dynamicMemberLookup
    class ViewModel: ObservableObject {
        var shouldRequestReview: Bool {
            #if DEBUG
            dataController.count(for: Tag.fetchRequest()) >= 0
            #else
            dataController.count(for: Tag.fetchRequest()) >= 5
            #endif
        }
        var dataController: DataController

        init(dataController: DataController) {
            self.dataController = dataController
        }

        subscript<Value>(dynamicMember keyPath: KeyPath<DataController, Value>) -> Value {
            dataController[keyPath: keyPath]
        }

        subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<DataController, Value>) -> Value {
            get { dataController[keyPath: keyPath] }
            // set { dataController[keyPath: keyPath] = newValue }
            set {
                    // 🔐 Sicherer Setzen mit Delay (nur bei @Published empfohlen!)
                    DispatchQueue.main.async {
                        self.dataController[keyPath: keyPath] = newValue
                    }
                }
        }

        func delete(_ offsets: IndexSet) {
            let issues = dataController.issuesForSelectedFilter()

            for offset in offsets {
                let item = issues[offset]
                dataController.delete(item)
            }
        }

        func openURL(_ url: URL) {
                if url.absoluteString.contains("newIssue") {
                    dataController.newIssue()
                } else if let issue = dataController.issue(with: url.absoluteString) {
                    dataController.selectedIssue = issue
                    dataController.selectedFilter = .all
                }
            }
    }
}
