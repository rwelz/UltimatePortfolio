//
//  SidebarViewModel.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 19.06.25.
//

import CoreData
import Foundation
import SwiftUI

extension SidebarView {
    @dynamicMemberLookup
    final class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        // MARK: - Core Data + Controller
        let dataController: DataController
        private let tagsController: NSFetchedResultsController<Tag>

        // MARK: - Published Properties
        @Published var tags = [Tag]()
        @Published var tagToRename: Tag?
        @Published var renamingTag = false
        @Published var tagName = ""
        @Published var showingAwards = false
        @Published var showingStore = false
        // @Published var selectedFilter: Filter?

        // MARK: - Computed Filters
        var tagFilters: [Filter] {
            tags.map { tag in
                Filter(
                    id: tag.tagID,
                    name: tag.tagName,
                    icon: "tag",
                    tag: tag
                )
            }
        }

        // MARK: - Init
        init(dataController: DataController) {
            self.dataController = dataController

            let request = Tag.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(
                    key: "name",
                    ascending: true,
                    selector: #selector(NSString.localizedStandardCompare(_:))
                )
            ]

            tagsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()
            tagsController.delegate = self

            do {
                try tagsController.performFetch()
                tags = tagsController.fetchedObjects ?? []
            } catch {
                print("⚠️ Failed to fetch tags: \(error.localizedDescription)")
            }
        }

        // MARK: - Dynamic Member Lookup (Value access)
        @MainActor
        subscript<Value>(
            dynamicMember keyPath: ReferenceWritableKeyPath<DataController, Value>
        ) -> Value {
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
                // Skip if no change to reduce unnecessary publishes.
                let oldValue = dataController[keyPath: keyPath]
                if let lhs = oldValue as? AnyHashable,
                   let rhs = newValue as? AnyHashable,
                   lhs == rhs { return }

                Task { @MainActor in
                    dataController[keyPath: keyPath] = newValue
                }
            }
        }

        // MARK: - Dynamic Member Lookup (Binding access)
        subscript<Value>(
            dynamicMember keyPath: ReferenceWritableKeyPath<DataController, Value>
        ) -> Binding<Value> {
            Binding(
                get: { self.dataController[keyPath: keyPath] },
                set: { newValue in
                    let oldValue = self.dataController[keyPath: keyPath]
                    if let lhs = oldValue as? AnyHashable,
                       let rhs = newValue as? AnyHashable,
                       lhs == rhs { return }
                    self.dataController[keyPath: keyPath] = newValue
                }
            )
        }

        // MARK: - NSFetchedResultsControllerDelegate
        func controllerDidChangeContent(
            _ controller: NSFetchedResultsController<NSFetchRequestResult>
        ) {
            if let newTags = controller.fetchedObjects as? [Tag] {
                self.tags = newTags
            }
        }

        // MARK: - Tag Handling
        func deleteTagAtOffset(_ offsets: IndexSet) {
            for offset in offsets {
                let tag = tags[offset]
                dataController.delete(tag)
            }
            dataController.save()
        }

        func deleteTagAtFilter(_ filter: Filter) {
            guard let tag = filter.tag else { return }
            dataController.delete(tag)
            dataController.save()
        }

        func rename(_ filter: Filter) {
            tagToRename = filter.tag
            tagName = filter.name
            renamingTag = true
        }

        func completeRename() {
            tagToRename?.name = tagName
            dataController.save()
        }
    }
}
