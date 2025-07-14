//
//  UltimatePortfolioApp.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 25.04.25.
//

import CoreSpotlight
import SwiftUI

@main
struct UltimatePortfolioApp: App {
    @StateObject var dataController = DataController() // @Published und @StateObject gehören zusammen

    @Environment(\.scenePhase) var scenePhase

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(dataController: dataController)
            } content: {
                ContentView(dataController: dataController)
            } detail: {
                DetailView()
            }
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController) // dataController wird als ein Environment Object bereitgestellt.
            // Ein @EnvironmentObject ist ein ObservableObject,
            // das von beliebigen Unter-Views genutzt werden kann,
            // ohne dass man es explizit als Parameter weitergeben muss. Das ist besonders nützlich,
            // wenn viele Views dieselben Daten brauchen.
            // Wenn sich dataController ändert, wird WindowGroup { ContentView() }
            // neu geladen

            .onChange(of: scenePhase) { phase in
                if phase != .active {
                    dataController.save()
                }
            }
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
        }
    }

    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            dataController.selectedIssue = dataController.issue(with: uniqueIdentifier)
            dataController.selectedFilter = .all
        }
    }
}
