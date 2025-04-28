//
//  UltimatePortfolioApp.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 25.04.25.
//

import SwiftUI

@main
struct UltimatePortfolioApp: App {
    
    @StateObject var dataController = DataController() // @Published und @StateObject gehören zusammen
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            }
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController) // dataController wird als ein Environment Object bereitgestellt.
            // Ein @EnvironmentObject ist ein ObservableObject, das von beliebigen Unter-Views genutzt werden kann, ohne dass man es explizit als Parameter weitergeben muss. Das ist besonders nützlich, wenn viele Views dieselben Daten brauchen.
            // Wenn sich dataController ändert, wird WindowGroup { ContentView() }
            // neu geladen
        }
    }
}
