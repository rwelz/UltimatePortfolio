//
//  SidebarViewModel.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 19.06.25.
//

import CoreData
import Foundation

extension SidebarView {
    @dynamicMemberLookup
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        var dataController: DataController

        private let tagsController: NSFetchedResultsController<Tag>
        @Published var tags = [Tag]()

        @Published var tagToRename: Tag?
        @Published var renamingTag = false
        @Published var tagName = ""

        var tagFilters: [Filter] {
            tags.map { tag in
                Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
            }
        }

        init(dataController: DataController) {
            self.dataController = dataController

            let request = Tag.fetchRequest()
            // request.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
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

            // now we finish the new initializer by executing the fetch request and assigning it to the tags property:
            do {
                try tagsController.performFetch()
                tags = tagsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch tags")
            }
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
                MainActor.assumeIsolated { }
                Task { @MainActor in
                    dataController[keyPath: keyPath] = newValue
                }
            }
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newTags = controller.fetchedObjects as? [Tag] {
                tags = newTags
            }
        }

        func delete(_ offsets: IndexSet) {
            for offset in offsets {
                let item = tags[offset]
                dataController.delete(item)
            }
        }

        func delete(_ filter: Filter) {
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
