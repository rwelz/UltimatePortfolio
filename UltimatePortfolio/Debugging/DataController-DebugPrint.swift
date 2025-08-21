//
//  DataController-DebugPrint.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 11.08.25.
//

import CoreData
import CloudKit

extension DataController {

    /// einfacher Fetch Request mit Ausgabe der Größe der Ergebnissmenge
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

    /// Fetch Request mit Sortierung der Ergebnissmenge
    /// und anschliessender Ausgabe der Metadaten.
    /// Gibt alle Issues mit CloudKit-Datenbank-Scope und recordName aus
    func debugPrintAllIssuesWithCloudKitInfo() {
    #if DEBUG
        let context = container.viewContext

        let request: NSFetchRequest<Issue> = Issue.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Issue.creationDate, ascending: true)]

        do {
            let issues = try context.fetch(request)
            print("🔍 Core Data: \(issues.count) Issues gefunden")

            // Spaltenbreiten definieren
            let titleWidth = 30
            let scopeWidth = 10
            let spacer = "  " // Zwei Leerzeichen zwischen Scope und Record Name

            // Überschrift
            let headerTitle = "Titel".padding(toLength: titleWidth, withPad: " ", startingAt: 0)
            let headerScope = "Scope".padding(toLength: scopeWidth, withPad: " ", startingAt: 0)
            let headerRecord = "Record Name"
            print("\(headerTitle)\(headerScope)\(spacer)\(headerRecord)")

            // Linie
            let lineLength = titleWidth + scopeWidth + spacer.count + headerRecord.count
            print(String(repeating: "-", count: lineLength))

            // Datenzeilen
            for issue in issues {
                let title = issue.issueTitle

                // 1️⃣ Store-URL → Scope bestimmen
                var scope = "❓"
                if let store = issue.objectID.persistentStore,
                   let storeURL = store.url,
                   let storeDescription = container.persistentStoreDescriptions.first(where: { $0.url == storeURL }),
                   let options = storeDescription.cloudKitContainerOptions {

                    switch options.databaseScope {
                    case .public:  scope = "🌍 Public"
                    case .private: scope = "🔒 Private"
                    case .shared:  scope = "🤝 Shared"
                    @unknown default: scope = "❓"
                    }
                }

                // 2️⃣ recordName ermitteln
                let recordName: String
                if let recordID = container.recordID(for: issue.objectID) {
                    recordName = recordID.recordName
                } else {
                    recordName = "(noch nicht synchronisiert)"
                }

                // 3️⃣ Ausgabe formatiert
                let titleCol = title.padding(toLength: titleWidth, withPad: " ", startingAt: 0)
                let scopeCol = scope.padding(toLength: scopeWidth, withPad: " ", startingAt: 0)
                print("\(titleCol)\(scopeCol)\(spacer)\(recordName)")
            }
        } catch {
            print("❌ Fehler beim Abrufen der Issues: \(error.localizedDescription)")
        }
    #endif
    }
}
