//
//  NewIssueIntent.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 21.07.25.
// xxx

import Foundation

import AppIntents
import SwiftUI

struct NewIssueIntent: AppIntent {

    static var title: LocalizedStringResource = "Neues Issue anlegen"

    @Parameter(title: "Name") // diese und die nächste Zeile gehören zusammen und dürfen nicht getrennt werden
    var name: String

    static var description = IntentDescription("Legt ein neues Issue an.")

    func perform() async throws -> some IntentResult {
        DataController().newIssue()
        await Manager.shared.setShowView(true)
        return .result()

    }
}
