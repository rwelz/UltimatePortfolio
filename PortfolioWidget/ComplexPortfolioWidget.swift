//
//  SimplePortfolioWidget.swift
//  SimplePortfolioWidget
//
//  Created by Robert Welz on 24.07.25.
//

import WidgetKit
import SwiftUI

struct ComplexProvider: TimelineProvider {
    // Apple’s widget template includes quite a lot of code for us already, but actually it’s the bare minimum required to get a meaningful widget:

    // There is one struct called Provider, which conforms to the TimelineProvider protocol. This determines how data for our widget is fetched.
    // There is another struct called SimpleEntry, which conforms to the TimelineEntry protocol. This determines how data for our widget is stored.
    // There is a third struct called SimplePortfolioWidgetEntryView, which conforms to SwiftUI’s View protocol. This determines how data for our widget is presented.
    // There is a fourth struct called SimplePortfolioWidget, which conforms to the Widget protocol. This determines how our widget should be configured.

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
        let request = dataController.fetchRequestForTopIssues(count: 7) // This new widget needs to show multiple issues, we need to change its loadIssues() method so that it returns more than just one issue, like this:
        //request.predicate = NSPredicate(format: "completed == true")
        request.predicate = NSPredicate(format: "completed == nil")
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

struct ComplexPortfolioWidgetEntryView : View {
    var entry: ComplexProvider.Entry

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
        .description("Your #1 top-priority issue.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    ComplexPortfolioWidget()
} timeline: {
    ComplexEntry(date: .now, issues: [.example])
    ComplexEntry(date: .now, issues: [.example])
}
