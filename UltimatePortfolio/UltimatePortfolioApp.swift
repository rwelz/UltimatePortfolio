//
//  UltimatePortfolioApp.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 25.04.25.
//

#if canImport(CoreSpotlight)
import CoreSpotlight
#endif
import SwiftUI

#if os(macOS)
import AppKit

func removeDeleteMenuItem() {
    if let mainMenu = NSApplication.shared.mainMenu,
       let editMenu = mainMenu.item(withTitle: "Edit")?.submenu {
        if let deleteItem = editMenu.item(withTitle: "Delete") {
            editMenu.removeItem(deleteItem)
            print("🗑 'Delete' aus Menü entfernt")
        }
    }
}
#endif

@main
struct UltimatePortfolioApp: App {
    @StateObject var dataController = DataController() // @Published und @StateObject gehören zusammen
    @Environment(\.scenePhase) var scenePhase

#if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
#endif

    @ObservedObject var manager = Manager.shared
    @State private var preferredColumn = NavigationSplitViewColumn.sidebar

    init() {
#if os(macOS)
        // Beobachte Menüänderungen und entferne "Delete" jedes Mal neu
        NotificationCenter.default.addObserver(
            forName: NSMenu.didAddItemNotification,
            object: nil,
            queue: .main
        ) { _ in
            // WICHTIG: erst im nächsten RunLoop löschen
            DispatchQueue.main.async {
                removeDeleteMenuItem()
            }
        }
#endif
    }

    var body: some Scene {
        WindowGroup {
            NavigationSplitView(
                preferredCompactColumn: $preferredColumn
            ) {
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

            // One nice side effect of this change here is that we can remove
            // one special case for visionOS, where we have one path for
            // purchasing StoreKit products on visionOS, and another for the other platforms
            // in DataController-StoreKit.swift
            .onChange(of: scenePhase) {
                if scenePhase != .active {
                    dataController.save()
                }
            }
            .onAppear {
#if os(macOS)
                DispatchQueue.main.async {
                    removeDeleteMenuItem()
                }
#endif
            }
#if canImport(CoreSpotlight)
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
#endif
            // .onReceive(manager.$showView) { newValue in
            //   print("manager.showView View geändert: \(newValue)")
            //   if newValue {
            //       preferredColumn = .content
            //       resetShowView()
            //   }
            // } // xxx
        }
    }

#if canImport(CoreSpotlight)
    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            dataController.selectedIssue = dataController.issue(with: uniqueIdentifier)
            dataController.selectedFilter = .all
        }
    }
#endif

    // func resetShowView() {
    //    if Manager.shared.showView == true {
    //        Manager.shared.showView = false
    //    }
    // }
}
