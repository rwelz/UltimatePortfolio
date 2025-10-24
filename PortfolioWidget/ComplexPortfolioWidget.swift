//
//  SimplePortfolioWidget.swift
//  SimplePortfolioWidget
//
//  Created by Robert Welz on 24.07.25.
//

import WidgetKit
import SwiftUI

struct ComplexProvider: TimelineProvider {
    // for more information about widgets structs see explanation at the top of SimplePortfolioWidget.swift and replace
    // SimpleProvider with ComplexProvider
    // SimpleEntry with ComplexEntry
    // SimplePortfolioWidgetEntryView with ComplexPortfolioWidgetEntryView
    // SimplePortfolioWidget with ComplexPortfolioWidget

    func placeholder(in context: Context) -> ComplexEntry {
        ComplexEntry(date: .now, issues: [.example])
    }

    func getSnapshot(in context: Context, completion: @escaping (ComplexEntry) -> Void) {
        let entry = ComplexEntry(date: Date.now, issues: loadIssues())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = ComplexEntry(date: Date.now, issues: loadIssues())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }

    //func loadIssues() -> [Issue] {
    //    let dataController = DataController()
    //    let request = dataController.fetchRequestForTopIssues(count: 1)
    //    let result:[Issue]  = dataController.results(for: request)
    //
    //    return result
    //}
    func loadIssues() -> [Issue] {
        let dataController = DataController()
        // This new widget needs to show multiple issues.
        // We need to change its loadIssues() method so that it returns more than just one issue.
        let request = dataController.fetchRequestForTopIssues(count: 7)
        let allIssues = dataController.results(for: request)
        //for issue in allIssues {
        //    print("Issue completed: \(String(describing: issue.completed))")
        //}

        return allIssues
    }
}

struct ComplexEntry: TimelineEntry {
    let date: Date
    let issues: [Issue]
}

struct ComplexPortfolioWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    let entry: ComplexProvider.Entry

    var issues: ArraySlice<Issue> {
        let issueCount: Int

        switch widgetFamily {
        case .systemSmall:
            issueCount = 1
        case .systemLarge, .systemExtraLarge:
            if dynamicTypeSize < .xxLarge {
                issueCount = 6
            } else {
                issueCount = 5
            }
        default:
            if dynamicTypeSize < .xLarge {
                issueCount = 3
            } else {
                issueCount = 2
            }
        }

        return entry.issues.prefix(issueCount)
    }



    var body: some View {
        VStack(spacing: 10) {
            ForEach(issues) { issue in
                Link(destination: issue.objectID.uriRepresentation()) {
                    VStack(alignment: .leading) {
                        Text(issue.issueTitle)
                            .font(.headline)
                            .layoutPriority(1)
                        
                        if issue.issueTags.isEmpty == false {
                            Text(issue.issueTagsList)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

struct ComplexPortfolioWidget: Widget {
    let kind: String = "ComplexPortfolioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ComplexProvider()) { entry in
            if #available(iOS 17.0, *) {
                ComplexPortfolioWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ComplexPortfolioWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Up next…")
        .description("Your most important issues.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

#Preview(as: .systemSmall) {
    ComplexPortfolioWidget()

} timeline: {
    ComplexEntry(date: .now, issues: [.example])
    ComplexEntry(date: .now, issues: [.example])
}

