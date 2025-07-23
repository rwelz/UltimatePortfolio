//
//  ContentView.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 25.04.25.
//

import SwiftUI

struct ContentView: View {

    @StateObject var viewModel: ViewModel
    @Environment(\.requestReview) var requestReview

    private let newIssueActivity = "de.robert.welz.UltimatePortfolio.newIssue"

    var body: some View {
        List(selection: $viewModel.selectedIssue) {
            ForEach(viewModel.dataController.issuesForSelectedFilter()) { issue in
                IssueRow(issue: issue)
            }
            .onDelete(perform: viewModel.delete)
        }
        .navigationTitle("Issues")
        .searchable(
            text: $viewModel.filterText,
            tokens: $viewModel.filterTokens,
            suggestedTokens: .constant(viewModel.suggestedFilterTokens),
            prompt: "Filter issues, or type # to add tags"
        ) { tag in
            Text(tag.tagName)
        }
        .toolbar(content: ContentViewToolbar.init)
        .onAppear(perform: askForReview)
        .onOpenURL(perform: openURL)
    }

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    func askForReview() {
        if viewModel.shouldRequestReview {
            requestReview()

    func openURL(_ url: URL) {
            if url.absoluteString.contains("newIssue") {
                viewModel.dataController.newIssue()
            }
        }

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

    func resumeActivity(_ userActivity: NSUserActivity) {
        viewModel.dataController.newIssue()
    }
}

#Preview {
    ContentView(dataController: .preview)
}
