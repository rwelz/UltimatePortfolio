//
//  SidebarViewToolbar.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 05.06.25.
//

import SwiftUI

struct SidebarViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    @Binding var showingAwards: Bool

    var body: some View {
#if DEBUG
            Button {
                dataController.deleteAll()
                dataController.createSampleData()
            } label: {
                Label("ADD SAMPLES", systemImage: "flame")
            }
#endif
            Button(action: dataController.newTag) {
                Label("Add tag", systemImage: "plus")
            }

            Button {
                showingAwards.toggle()
            } label: {
                Label("Show awards", systemImage: "rosette")
            }
    }
}

#Preview {
    SidebarViewToolbar(showingAwards: .constant(true))
}
