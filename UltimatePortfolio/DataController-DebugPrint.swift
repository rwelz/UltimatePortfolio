//
//  DataController-DebugPrint.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 11.08.25.
//

import CoreData
import CloudKit

extension DataController {

    func debugPrintIssueCount() {
        let context = container.viewContext
        let request: NSFetchRequest<Issue> = Issue.fetchRequest()
        do {
            let count = try context.count(for: request)
            print("🐻 Anzahl Issues im Core Data Store: \(count)")
        } catch {
            print("❌ Fehler beim Zählen der Issues: \(error.localizedDescription)")
        }
    }

    /// Gibt alle Issues mit CloudKit-Datenbank-Scope und recordName aus
    func debugPrintAllIssuesWithCloudKitInfo() {
#if DEBUG
        let context = container.viewContext

        let request: NSFetchRequest<Issue> = Issue.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Issue.creationDate, ascending: true)]

        do {
            let issues = try context.fetch(request)
            print("🔍 Core Data: \(issues.count) Issues gefunden")
            print("Titel                         Scope      recordName")
            print(String(repeating: "-", count: 70))

            for issue in issues {
                let title = issue.issueTitle

                // 1️⃣ Store-URL → Scope bestimmen
                var scope = "❓"
                if let store = issue.objectID.persistentStore,
                   let storeURL = store.url,
                   let storeDescription = container.persistentStoreDescriptions.first(where: { $0.url == storeURL }),
                   let options = storeDescription.cloudKitContainerOptions {

                    switch options.databaseScope {
                    case .public: scope = "🌍 Public"
                    case .private: scope = "🔒 Private"
                    case .shared: scope = "🤝 Shared"
                    @unknown default: scope = "❓"
                    }
                }

                // 2️⃣ recordName ermitteln → optional entpacken
                var recordName = "(nicht verfügbar)"
                if let recordID = container.recordID(for: issue.objectID) {
                    recordName = recordID.recordName
                } else {
                    recordName = "(noch nicht synchronisiert)"
                }

                // 3️⃣ Ausgabe formatiert
                print(String(format: "%-30s %-10s %@", title, scope, recordName))
            }

        } catch {
            print("❌ Fehler beim Abrufen der Issues: \(error.localizedDescription)")
        }
#endif
    }
}
