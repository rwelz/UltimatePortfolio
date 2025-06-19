//
//  SidebarView.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 28.04.25.
//

import SwiftUI

struct SidebarView: View {
    @State private var showingAwards = false
    @StateObject private var viewModel: ViewModel
    let smartFilters: [Filter] = [.all, .recent]

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(selection: $viewModel.dataController.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilters, content: SmartFilterRow.init)
//                ForEach(smartFilters) { filter in
//                    NavigationLink(value: filter) {
//                        Label(LocalizedStringKey(filter.name), systemImage: filter.icon)
//                    }
//                }
            }
            Section("Tags") {
                ForEach(viewModel.tagFilters) { filter in
                    UserFilterRow(filter: filter, rename: viewModel.rename, delete: viewModel.delete)
                }
                .onDelete(perform: viewModel.delete)
            }
        }
        .toolbar {
            SidebarViewToolbar(showingAwards: $showingAwards)
        }
        .alert("Rename tag", isPresented: $viewModel.renamingTag) {
            Button("OK", action: viewModel.completeRename)
            Button("Cancel", role: .cancel) { }
            TextField("New name", text: $viewModel.tagName)
        }
        .sheet(isPresented: $showingAwards, content: AwardsView.init)
        .navigationTitle("Filters")
    }
}

#Preview {
    SidebarView(dataController: .preview)
}
