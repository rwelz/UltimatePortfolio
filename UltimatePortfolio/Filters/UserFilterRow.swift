//
//  UserFilterRow.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 05.06.25.
//

import SwiftUI

struct UserFilterRow: View {
    @EnvironmentObject var dataController: DataController

    var filter: Filter
    var rename: (Filter) -> Void
    var delete: (Filter) -> Void

    var body: some View {
        NavigationLink(value: filter) {
            Label(filter.tag?.name ?? "No name", systemImage: filter.icon)
                .numberBadge(filter.activeIssuesCount)
                .contextMenu {
                    Button {
                        rename(filter)
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        delete(filter)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .accessibilityElement()
                .accessibilityLabel(filter.name)
		// internationalized in stringdict file
                .accessibilityHint("\(filter.activeIssuesCount) issues")
        }
    }
}

struct UserFilterRow_Previews: PreviewProvider {
    static var previews: some View {
        UserFilterRow(filter: .all, rename: { _ in }, delete: { _ in })
    }
}

// #Preview {
//    UserFilterRow(filter: .all, rename: { _ in }, delete: { _ in })
// }
