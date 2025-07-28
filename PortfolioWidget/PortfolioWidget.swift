//
//  PortfolioWidget.swift
//  PortfolioWidget
//
//  Created by Robert Welz on 24.07.25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    // Apple’s widget template includes quite a lot of code for us already, but actually it’s the bare minimum required to get a meaningful widget:

    // There is one struct called Provider, which conforms to the TimelineProvider protocol. This determines how data for our widget is fetched.
    // There is another struct called SimpleEntry, which conforms to the TimelineEntry protocol. This determines how data for our widget is stored.
    // There is a third struct called PortfolioWidgetEntryView, which conforms to SwiftUI’s View protocol. This determines how data for our widget is presented.
    // There is a fourth struct called PortfolioWidget, which conforms to the Widget protocol. This determines how our widget should be configured.

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

    //func loadIssues() -> [Issue] {
    //    let dataController = DataController()
    //    let request = dataController.fetchRequestForTopIssues(count: 1)
    //    let result:[Issue]  = dataController.results(for: request)
    //
    //    return result
    //}
    func loadIssues() -> [Issue] {
        let dataController = DataController()
        let request = Issue.fetchRequest()
        //request.predicate = NSPredicate(format: "completed == true")
        request.predicate = NSPredicate(format: "completed == nil")
        let allIssues = dataController.results(for: request)
        //for issue in allIssues {
        //    print("Issue completed: \(String(describing: issue.completed))")
        //}

        return allIssues
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let issues: [Issue]
}

struct PortfolioWidgetEntryView : View {
    var entry: Provider.Entry

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

struct PortfolioWidget: Widget {
    let kind: String = "PortfolioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PortfolioWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PortfolioWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    PortfolioWidget()
} timeline: {
    SimpleEntry(date: .now, issues: [.example])
    SimpleEntry(date: .now, issues: [.example])
}
