//
//  SimplePortfolioWidget.swift
//  SimplePortfolioWidget
//
//  Created by Robert Welz on 24.07.25.
//

import WidgetKit
import SwiftUI

struct SimpleProvider: TimelineProvider {
    // Apple’s widget template includes quite a lot of code for us already, but actually it’s the bare minimum required to get a meaningful widget:

    // There is one struct called SimpleProvider, which conforms to the TimelineProvider protocol. This determines how data for our widget is fetched.
    // There is another struct called SimpleEntry, which conforms to the TimelineEntry protocol. This determines how data for our widget is stored.
    // There is a third struct called SimplePortfolioWidgetEntryView, which conforms to SwiftUI’s View protocol. This determines how data for our widget is presented.
    // There is a fourth struct called SimplePortfolioWidget, which conforms to the Widget protocol. This determines how our widget should be configured.

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, issues: [.example])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date.now, issues: loadIssues())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = SimpleEntry(date: Date.now, issues: loadIssues())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }

    func loadIssues() -> [Issue] {
        let dataController = DataController()
        let request = dataController.fetchRequestForTopIssues(count: 1)
        let result:[Issue]  = dataController.results(for: request)

        MyUnifiedLogger.logTopIssues(resultSet: result, category: "Widget")
        MyUnifiedLogger.logIssuesCount(resultSet: result, category: "Widget")

        return result
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let issues: [Issue]
}

struct SimplePortfolioWidgetEntryView: View {
    var entry: SimpleProvider.Entry

    var body: some View {
        VStack {
            Text("Up next…")
                .font(.title)

            if let issue = entry.issues.first {
                Text(issue.issueTitle)
            } else {
                Text("Nothing!")
            }
        }
    }
}

struct SimplePortfolioWidget: Widget {
    let kind: String = "SimplePortfolioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleProvider()) { entry in
            if #available(iOS 17.0, *) {
                SimplePortfolioWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                SimplePortfolioWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Up next…")
        .description("Your #1 top-priority issue.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    SimplePortfolioWidget()
} timeline: {
    SimpleEntry(date: .now, issues: [.example])
    SimpleEntry(date: .now, issues: [.example])
}
