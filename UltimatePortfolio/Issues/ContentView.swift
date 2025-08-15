//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 25.04.25.
//

import SwiftUI

struct ContentView: View {

    @StateObject var viewModel: ViewModel

    @EnvironmentObject var dataController: DataController

#if !os(watchOS)
    @Environment(\.requestReview) var requestReview
#endif

    private let newIssueActivity = "de.robert.welz.UltimatePortfolio.newIssue"

    var body: some View {
        List(selection: $viewModel.selectedIssue) {
            ForEach(viewModel.dataController.issuesForSelectedFilter()) { issue in
                #if os(watchOS)
                IssueRowWatch(issue: issue)
                #else
                IssueRow(issue: issue)
                #endif
            }
            .onDelete(perform: viewModel.delete)
        }
        .macFrame(minWidth: 220)
        .navigationTitle("Issues")
#if !os(watchOS)
        .searchable(
            text: $viewModel.filterText,
            tokens: $viewModel.filterTokens,
            suggestedTokens: .constant(viewModel.suggestedFilterTokens),
            prompt: "Filter issues, or type # to add tags"
        ) { tag in
            Text(tag.tagName)
        }
        #endif
        .toolbar(content: ContentViewToolbar.init)
        // .onAppear(perform: askForReview)
        .onAppear {
            askForReview()
            // dataController.debugPrintIssueCount()
            // dataController.debugPrintAllIssuesWithCloudKitInfo()
        }
        .onOpenURL(perform: viewModel.openURL)
    }

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

// TODO: gibt es einen Ersatz für diese Funktion in macOS, oder kann ich die auf macOS ersatzlos streichen?
    #if os(iOS)
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let shortcutItem = connectionOptions.shortcutItem {
            if let url = URL(string: shortcutItem.type) {
                scene.open(url, options: nil)
            }
        }
    }
    #endif

    func askForReview() {
#if !os(watchOS)
        if viewModel.shouldRequestReview {
            requestReview()
        }
#endif
    }
}

#Preview {
    ContentView(dataController: .preview)
        .environmentObject(DataController(inMemory: true))
}
