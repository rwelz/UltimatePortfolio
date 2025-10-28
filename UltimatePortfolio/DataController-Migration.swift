//
//  DataController-Migration.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 28.10.25.
//

import Foundation
import CoreData

extension DataController {
    /// Füllt für bestehende Issues fehlende modificationDates nach der Migration.
    func migrateMissingModificationDates() {
        let context = container.viewContext
        let request = NSFetchRequest<Issue>(entityName: "Issue")
        request.predicate = NSPredicate(format: "modificationDate == nil")
        
        do {
            let results = try context.fetch(request)
            print("🔎 Migration: \(results.count) Issues ohne modificationDate gefunden")
            
            for issue in results {
                // Fallback: wenn es ein creationDate gibt → übernehmen
                if let created = issue.creationDate {
                    issue.modificationDate = created
                } else {
                    // sonst auf jetzt setzen
                    issue.modificationDate = Date()
                }
            }
            
            if context.hasChanges {
                try context.save()
                print("✅ Migration abgeschlossen: modificationDate ergänzt")
            }
        } catch {
            print("❌ Migration-Fehler: \(error.localizedDescription)")
        }
    }
}
