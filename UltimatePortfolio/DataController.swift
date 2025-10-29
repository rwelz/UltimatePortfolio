//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 26.04.25.
//  xxx ganz umschreiben, habv viele Änderungen zurückgenommen!
import CoreData
import StoreKit

#if canImport(WidgetKit)
import WidgetKit
#endif

enum SortType: String {
    case dateCreated = "creationDate"
    case dateModified = "modificationDate"
}

enum Status {
    case all, open, closed
}

/// An environment singleton responsible for managing our Core Data stack, including handling saving,
/// counting fetch requests, tracking orders, and dealing with sample data.
class DataController: ObservableObject {
    /// The lone CloudKit container used to store all our data.
    let container: NSPersistentCloudKitContainer

#if !os(watchOS)
    var spotlightDelegate: NSCoreDataCoreSpotlightDelegate?
#endif

    @Published var selectedFilter: Filter? = Filter.all
    @Published var selectedIssue: Issue?

    @Published var filterText = ""
    @Published var filterTokens = [Tag]()

    @Published var filterEnabled = false
    @Published var filterPriority = -1
    @Published var filterStatus = Status.all
    @Published var sortType = SortType.dateCreated
    @Published var sortNewestFirst = true

    private var storeTask: Task<Void, Never>?
    private var saveTask: Task<Void, Error>?

    /// The UserDefaults suite where we're saving user data.
    let defaults: UserDefaults

    /// The StoreKit products we've loaded for the store.
    @Published var products = [Product]()

    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()

    var suggestedFilterTokens: [Tag] {
        guard filterText.starts(with: "#") else {
            return []
        }

        let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()

        if trimmedFilterText.isEmpty == false {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }

        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }

    // singleton
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Model", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()

    // swiftlint:disable function_body_length
    /// Initializes a data controller, either in memory (for temporary use such as testing and previewing),
    /// or on permanent storage (for use in regular app runs.)
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    /// - Parameter defaults: The UserDefaults suite where user data should be stored.
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
        self.defaults = defaults

        // using the singleton
        container = NSPersistentCloudKitContainer(name: "Model", managedObjectModel: Self.model)

        storeTask = Task {
            await monitorTransactions()
        }

        // For testing and previewing purposes, we create a
        // temporary, in-memory database by writing to /dev/null
        // so our data is destroyed after the app finishes running.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // we'r using our App Groups capability,
            // so the database can be shared between different targets or apps belonging to myself
            let groupID = "group.de.robert.welz.UltimatePortfol.upa"

            if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
                container.persistentStoreDescriptions.first?.url = url.appending(path: "Main.sqlite")
            }
        }
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

            // Make sure that we watch iCloud for all changes to make
            // absolutely sure we keep our local UI in sync when a
            // remote change happens.
            container.persistentStoreDescriptions.first?.setOption(
                true as NSNumber,
                forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
            )

            if let description = container.persistentStoreDescriptions.first {
                description.shouldMigrateStoreAutomatically = true
                description.shouldInferMappingModelAutomatically = true
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                description.setOption(
                    true as NSNumber,
                    forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
                ) // xxx
            }

            // Im visionOS Simulator gibt es diese Notification nicht:
            // CloudKit mldet keine Änderung und somit wird diese benachrichtigung nicht gesendet
            // nur bei einem Neustart ( Restart ) der App werden neue Daten aus der Cloud geladen.
            //        Warum deine visionOS-Simulator-App keine frischen CloudKit-Daten bekommt
            //            1.    Simulator ≠ echter CloudKit-Zugriff
            //                  •    Der visionOS-Simulator hat (Stand 2025) keinen echten CloudKit-Zugang.
            //                  •    Er kann weder in iCloud einloggen noch Live-Push-Notifications empfangen.
            //                  •    Alles, was er sieht, kommt nur aus der lokalen SQLite-Datenbank,
            //                         die Core Data für ihn im Simulator-Dateisystem anlegt.
            //            2.    Push-Mechanismus fehlt
            //                  •    Unter iOS-Simulator kannst du Debug → Simulate CloudKit Push nutzen,
            //                       um eine NSPersistentStoreRemoteChange auszulösen.
            //                  •    Unter visionOS-Simulator gibt es diesen Menüpunkt nicht →
            //                       keine automatischen Updates aus der Cloud.

            NotificationCenter.default.addObserver(
                forName: .NSPersistentStoreRemoteChange,
                object: container.persistentStoreCoordinator,
                queue: .main,
                using: remoteStoreChanged
            )

            container.loadPersistentStores { [weak self] description, error in
                if let error {
                    fatalError("Fatal error loading store: \(error.localizedDescription)")
                } else {
#if DEBUG
                    print("✅ Persistent Store geladen:", description.url?.absoluteString ?? "unbekannt")

                    // Debug: alle Issues zählen
                    let request = NSFetchRequest<Issue>(entityName: "Issue")
                    let count = (try? self?.container.viewContext.count(for: request)) ?? -1
                    print("🔎 Anzahl Issues im Store:", count)
#endif
                    // Migration: fehlende modificationDates nachpflegen
                    self?.migrateMissingModificationDates()
                }

                if let description = self?.container.persistentStoreDescriptions.first {
                    description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

#if !os(watchOS)
                    if let coordinator = self?.container.persistentStoreCoordinator {
                        self?.spotlightDelegate = NSCoreDataCoreSpotlightDelegate(
                            forStoreWith: description,
                            coordinator: coordinator
                        )

                        self?.spotlightDelegate?.startSpotlightIndexing()
                    }
#endif
                }

#if DEBUG
                if CommandLine.arguments.contains("enable-testing") {
                    self?.deleteAll()
#if os(iOS)
                    UIView.setAnimationsEnabled(false)
#endif
                }
#endif
            }
        }
    }
    // swiftlint:enable function_body_length

    func remoteStoreChanged(_ notification: Notification) {
        // do {
        // let name = UIDevice.current.name
        // print("📱 Device name is: \(name)")

        //    try container.viewContext.setQueryGenerationFrom(.current)
        //    container.viewContext.refreshAllObjects()

        //    print("🔥 Remote Change Notification erhalten!")

        // } catch {
        //    print("❌ Fehler beim Refresh des Core Data Context: \(error.localizedDescription)")
        // } // xxx

        objectWillChange.send()
    }

    func createSampleData() {
        let viewContext = container.viewContext

        for tagCounter in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(tagCounter)"

            for issueCounter in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(tagCounter)-\(issueCounter)"
                issue.content = "Description goes here"
                issue.creationDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue)
            }
        }

        try? viewContext.save()
    }

    func updateModificationDates() {
        let context = container.viewContext
        let updatedObjects = context.updatedObjects.union(context.insertedObjects)

        for case let issue as Issue in updatedObjects {
            if issue.creationDate == nil {
                issue.creationDate = Date()
            }
            issue.modificationDate = Date()
        }
    }

    /// Saves our Core Data context iff there are changes. This silently ignores
    /// any errors caused by saving, but this should be fine because all our attributes are optional.
    /// the “iff” part (yes, with a double F) means “if and only if”.
    /// You see, “save if we have changes” doesn’t mean “don’t save if we don’t have changes,” so it’s good to be clear.
    func save() {
        saveTask?.cancel()

        updateModificationDates()

        if container.viewContext.hasChanges {
            try? container.viewContext.save()

#if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
#endif
        }
    }

    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }

    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        // ⚠️ When performing a batch delete we need to make sure we read the result back
        // then merge all the changes from that result back into our live view context
        // so that the two stay in sync.
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }

    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)

        let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        delete(request2)

        save()
    }

    func missingTags(from issue: Issue) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []

        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(issue.issueTags)

        return difference.sorted { lhs, rhs in
            let left = lhs.name ?? ""
            let right = rhs.name ?? ""
            return left.localizedStandardCompare(right) == .orderedAscending
        }
    }

    // func queueSave() {
    //    saveTask?.cancel()

    //    saveTask = Task { @MainActor in
    //        try await Task.sleep(for: .seconds(3))
    //        save()
    //    }
    // } // xxx

    /// Runs a fetch request with various predicates that filter the user's issues based on
    /// tag, title and content text, search tokens, priority, and completion status.
    /// - Returns: An array of all matching issues.
    func issuesForSelectedFilter() -> [Issue] {
        let filter = selectedFilter ?? .all
        var predicates = [NSPredicate]()

        if let tag = filter.tag {
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
        } else {
            let datePredicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            predicates.append(datePredicate)
        }

        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)

        if trimmedFilterText.isEmpty == false {
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedFilterText)

            let combinedPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [titlePredicate, contentPredicate]
            )

            predicates.append(combinedPredicate)
        }

        //        if filterTokens.isEmpty == false {
        //            let tokenPredicate = NSPredicate(format: "ANY tags IN %@", filterTokens)
        //            predicates.append(tokenPredicate)
        //        }

        if filterTokens.isEmpty == false {
            for filterToken in filterTokens {
                let tokenPredicate = NSPredicate(format: "tags CONTAINS %@", filterToken)
                predicates.append(tokenPredicate)
            }
        }

        if filterEnabled {
            if filterPriority >= 0 {
                let priorityFilter = NSPredicate(format: "priority = %d", filterPriority)
                predicates.append(priorityFilter)
            }

            if filterStatus != .all {
                let lookForClosed = filterStatus == .closed
                let statusFilter = NSPredicate(format: "completed = %@", NSNumber(value: lookForClosed))
                predicates.append(statusFilter)
            }
        }

        let request = Issue.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortNewestFirst)]

        let allIssues = (try? container.viewContext.fetch(request)) ?? []

        MyUnifiedLogger.logTopIssues(resultSet: allIssues, loglevel: .notice)
        MyUnifiedLogger.logIssuesCount(resultSet: allIssues, loglevel: .notice)

        return allIssues
    }

    func newTag() -> Bool {
        var shouldCreate = fullVersionUnlocked

        if shouldCreate == false {
            // check how many tags we currently have
            shouldCreate = count(for: Tag.fetchRequest()) < 3
        }

        guard shouldCreate else {
            return false
        }

        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        tag.name = NSLocalizedString("New tag", comment: "Create a new tag")
        save()
        return true
    }

    func newIssue() {
        let issue = Issue(context: container.viewContext)
        issue.title = NSLocalizedString("New issue", comment: "Create a new issue")
        issue.creationDate = .now
        issue.priority = 1

        issue.completed = false // xxx

        // If we are currently browsing a user-created tag, immediately
        // add this new issue to the tag otherwise it won't appear in
        // the list of issues they see.
        if let tag = selectedFilter?.tag {
            issue.addToTags(tag)
        }
        save()
        selectedIssue = issue
        "New Issue Created".debugLog()
    }

    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    func issue(with uniqueIdentifier: String) -> Issue? {
        guard let url = URL(string: uniqueIdentifier) else {
            return nil
        }

        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }

        return try? container.viewContext.existingObject(with: id) as? Issue
    }

    func fetchRequestForTopIssues(count: Int) -> NSFetchRequest<Issue> {
        let request = Issue.fetchRequest()
        request.predicate = NSPredicate(format: "completed = false")

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Issue.priority, ascending: false)
        ]

        request.fetchLimit = count
        return request
    }

    func results<T: NSManagedObject>(for fetchRequest: NSFetchRequest<T>) -> [T] {
        return (try? container.viewContext.fetch(fetchRequest)) ?? []
    }
}
