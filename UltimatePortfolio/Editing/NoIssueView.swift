//
//  NoIssueView.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 15.05.25.
//

import SwiftUI

struct NoIssueView: View {
    @EnvironmentObject var dataController: DataController

    var body: some View {
        Text("No Issue Selected")
            .font(.title)
            .foregroundStyle(.secondary)

        Button("New Issue", action: dataController.newIssue)
    }
}
#Preview {
    NoIssueView()
        .environmentObject(DataController(inMemory: true))
}
