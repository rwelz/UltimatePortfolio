//
//  DataController-Deletions.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 27.10.25.
//

import Foundation
import CoreData

extension DataController {

    // Snapshot der Issues anlegen
    private struct IssueSnapshot {
        let title: String?
        let content: String?
        let creationDate: Date?
        let modificationDate: Date?
        let completed: Bool
        let priority: Int16
        let tags: [Tag]
    }

    func delete(_ issues: [Issue], using undoManager: UndoManager?) {
        let context = container.viewContext
        guard issues.isEmpty == false else { return }

        let snapshots: [IssueSnapshot] = issues.map { issue in
            IssueSnapshot(
                title: issue.title,
                content: issue.content,
                creationDate: issue.creationDate,
                modificationDate: issue.modificationDate,
                completed: issue.completed,
                priority: issue.priority,
                tags: issue.issueTags
            )
        }

        // Löschen
        for issue in issues {
            context.delete(issue)
        }

        do {
            try context.save()

            // Undo registrieren
            undoManager?.registerUndo(withTarget: self) { _ in
                for snap in snapshots {
                    let restored = Issue(context: context)
                    restored.title = snap.title
                    restored.content = snap.content
                    restored.creationDate = snap.creationDate
                    restored.modificationDate = snap.modificationDate
                    restored.completed = snap.completed
                    restored.priority = snap.priority
                    for tag in snap.tags {
                        restored.addToTags(tag)
                    }
                }

                // Speichern deferred, um Undo-Verschachtelung zu vermeiden
                DispatchQueue.main.async {
                    do {
                        try context.save()
                    } catch {
                        print("❌ Fehler beim Undo-Speichern: \(error.localizedDescription)")
                    }
                }
            }

            undoManager?.setActionName(
                issues.count == 1 ? "Delete Issue" : "Delete \(issues.count) Issues"
            )
        } catch {
            print("❌ Fehler beim Löschen: \(error.localizedDescription)")
        }
    }
}
