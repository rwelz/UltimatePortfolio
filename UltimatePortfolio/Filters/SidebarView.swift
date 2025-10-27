//
//  SidebarView.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 28.04.25.
//

import SwiftUI

struct SidebarView: View {
    @StateObject private var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
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
                // TODO:
                //                ForEach(smartFilters) { filter in
                //                    NavigationLink(value: filter) {
                //                        Label(LocalizedStringKey(filter.name), systemImage: filter.icon)
                //                    }
                //                } // xxx
            }
            Section("Tags") {
                ForEach(viewModel.tagFilters) { filter in
                    UserFilterRow(filter: filter, rename: viewModel.rename, delete: viewModel.deleteTagAtFilter)
                }
                .onDelete(perform: viewModel.deleteTagAtOffset)
            }
#if os(watchOS)
            // Aktionen direkt in der Liste
#if DEBUG
            Section("Debug") {
                Button(role: .destructive) {
                    viewModel.dataController.deleteAll()
                } label: {
                    Label("DELETE ALL", systemImage: "minus")
                }

                Button {
                    viewModel.dataController.deleteAll()
                    viewModel.dataController.createSampleData()
                } label: {
                    Label("ADD SAMPLES", systemImage: "flame")
                }
            }
#endif
#endif
        }
        .macFrame(minWidth: 220)
        .navigationTitle("Filters")
        .toolbar(content: SidebarViewToolbar.init)
        // Plattform-spezifische Darstellung
#if os(watchOS)
        .sheet(isPresented: $viewModel.renamingTag) {
            VStack(spacing: 12) {
                Text("Rename tag")
                    .font(.headline)

                TextField("New name", text: $viewModel.tagName)

                HStack {
                    Button("Cancel", role: .cancel) {
                        viewModel.renamingTag = false
                        dismiss()
                    }
                    Button("OK") {
                        viewModel.completeRename()
                        viewModel.renamingTag = false
                        dismiss()
                    }
                }
            }
            .padding()
        }
        // Extra Sheets für Awards/Store
        .sheet(isPresented: $viewModel.showingAwards, content: AwardsView.init)
        .sheet(isPresented: $viewModel.showingStore, content: StoreView.init)

#else
        // iOS/macOS: Alert
        .alert("Rename tag", isPresented: $viewModel.renamingTag) {
            TextField("New name", text: $viewModel.tagName)
            Button("OK", action: viewModel.completeRename)
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $viewModel.showingAwards, content: AwardsView.init)
        .sheet(isPresented: $viewModel.showingStore, content: StoreView.init)
#endif
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
