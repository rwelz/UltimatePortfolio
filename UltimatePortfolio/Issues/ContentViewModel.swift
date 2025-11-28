//
//  ContentViewModel.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 20.06.25.
//

import Foundation
import Combine

extension ContentView {
    @dynamicMemberLookup
    class ViewModel: ObservableObject {
        var dataController: DataController

        // Explicit publisher to satisfy ObservableObject and allow manual change emission

        // fixed the App Store review message being shown time and time again
        // once our initial check for eligibility passes.
        // This only happens in development mode,
        // mind you – in release mode Apple should be regulating this for us
        // so that users aren't shown the request more than three times a year.
        // Still, there's no harm being sure: we can update our code
        // so that we show the request every 10 launches,
        // to avoid nagging them too much.
        // That internally tracks a counter to ensure we don't show the alert too often –
        // a small improvement, but a welcome one.

        var shouldRequestReview: Bool {
            if dataController.count(for: Tag.fetchRequest()) >= 5 {
                let reviewRequestCount = UserDefaults.standard.integer(forKey: "reviewRequestCount")
                UserDefaults.standard.set(reviewRequestCount + 1, forKey: "reviewRequestCount")

                if reviewRequestCount.isMultiple(of: 10) {
                    return true
                }
            }

            return false
        }

        // func recordDidRequestReview() {
        //    let reviewRequestCount = UserDefaults.standard.integer(forKey: "reviewRequestCount")
        //    UserDefaults.standard.set(reviewRequestCount + 1, forKey: "reviewRequestCount")
        // } // xxx

        init(dataController: DataController) {
            self.dataController = dataController
        }

        subscript<Value>(dynamicMember keyPath: KeyPath<DataController, Value>) -> Value {
            dataController[keyPath: keyPath]
        }

        @MainActor
        subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<DataController, Value>) -> Value {
            get {
//                #if DEBUG
//                if let name = keyPath._kvcKeyPathString {
//                    print("GET dynamicMember:", name)
//                }
//                #endif
                return dataController[keyPath: keyPath]
            }
            set {
//                #if DEBUG
//                // Property-Namen ermitteln
//                let name = keyPath._kvcKeyPathString ?? String(describing: keyPath)
//                print("SET dynamicMember:", name, "→", newValue)
//                // Stacktrace vereinfachen
//                let trace = Thread.callStackSymbols
//                    .filter { $0.contains("UltimatePortfolio") || $0.contains("SwiftUI") }
//                // .prefix(8)
//                    .joined(separator: "\n→ ")
//                print("⚙️ Callstack (kurz):\n→ \(trace)\n")
//                #endif
                // dataController[keyPath: keyPath] = newValue // offending instruction
                // Avoid publishing during view updates by deferring mutation.
                let oldValue = dataController[keyPath: keyPath]
                // Skip if no change to reduce unnecessary publishes.
                if let lhs = oldValue as? AnyHashable, let rhs = newValue as? AnyHashable, lhs == rhs {
                    return
                }

                Task { @MainActor in
                    dataController[keyPath: keyPath] = newValue
                }
            }
        }

        func deleteItem(_ offsets: IndexSet) {
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
