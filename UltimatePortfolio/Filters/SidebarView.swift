//
//  SidebarView.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 28.04.25.
//

import SwiftUI

struct SidebarView: View {
    @StateObject private var viewModel: ViewModel

    let smartFilters: [Filter] = [.all, .recent]

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        // List(selection: $viewModel.dataController.selectedFilter) {
        List(selection: $viewModel.selectedFilter) { // thats what subsript in SidebarViewModel is for
            Section("Smart Filters") {
                ForEach(smartFilters, content: SmartFilterRow.init)
//                ForEach(smartFilters) { filter in
//                    NavigationLink(value: filter) {
//                        Label(LocalizedStringKey(filter.name), systemImage: filter.icon)
//                    }
//                } // xxx
            }
            Section("Tags") {
                ForEach(viewModel.tagFilters) { filter in
                    UserFilterRow(filter: filter, rename: viewModel.rename, delete: viewModel.delete)
                }
                .onDelete(perform: viewModel.delete)
            }
        }
        .macFrame(minWidth: 220)
        .toolbar(content: SidebarViewToolbar.init)
        .alert("Rename tag", isPresented: $viewModel.renamingTag) {
            Button("OK", action: viewModel.completeRename)
            Button("Cancel", role: .cancel) { }
            TextField("New name", text: $viewModel.tagName)
        }
        .navigationTitle("Filters")
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView(dataController: .preview)
    }
}

//  #Preview {
//    SidebarView(dataController: .preview)
// }
